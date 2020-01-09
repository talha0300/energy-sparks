# == Schema Information
#
# Table name: schools
#
#  address                               :text
#  calendar_id                           :bigint(8)
#  cooks_dinners_for_other_schools       :boolean          default(FALSE), not null
#  cooks_dinners_for_other_schools_count :integer
#  cooks_dinners_onsite                  :boolean          default(FALSE), not null
#  created_at                            :datetime         not null
#  dark_sky_area_id                      :bigint(8)
#  floor_area                            :decimal(, )
#  has_solar_panels                      :boolean          default(FALSE), not null
#  has_swimming_pool                     :boolean          default(FALSE), not null
#  id                                    :bigint(8)        not null, primary key
#  level                                 :integer          default(0)
#  met_office_area_id                    :bigint(8)
#  name                                  :string
#  number_of_pupils                      :integer
#  postcode                              :string
#  process_data                          :boolean          default(FALSE)
#  school_group_id                       :bigint(8)
#  school_type                           :integer
#  serves_dinners                        :boolean          default(FALSE), not null
#  slug                                  :string
#  solar_irradiance_area_id              :bigint(8)
#  solar_pv_tuos_area_id                 :bigint(8)
#  temperature_area_id                   :bigint(8)
#  template_calendar_id                  :integer
#  updated_at                            :datetime         not null
#  urn                                   :integer          not null
#  validation_cache_key                  :string           default("initial")
#  visible                               :boolean          default(FALSE)
#  website                               :string
#
# Indexes
#
#  index_schools_on_calendar_id      (calendar_id)
#  index_schools_on_school_group_id  (school_group_id)
#  index_schools_on_urn              (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (calendar_id => calendars.id)
#  fk_rails_...  (school_group_id => school_groups.id)
#

require 'securerandom'

class School < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: [:finders, :slugged, :history]

  delegate :holiday_approaching?, :next_holiday, to: :calendar

  has_and_belongs_to_many :key_stages, join_table: :school_key_stages

  has_many :users,                dependent: :destroy
  has_many :meters,               inverse_of: :school, dependent: :destroy
  has_many :school_times,         inverse_of: :school, dependent: :destroy
  has_many :activities,           inverse_of: :school, dependent: :destroy
  has_many :contacts,             inverse_of: :school, dependent: :destroy
  has_many :observations,         inverse_of: :school, dependent: :destroy
  has_many :meter_attributes,     inverse_of: :school, class_name: 'SchoolMeterAttribute'

  has_many :programmes,               inverse_of: :school, dependent: :destroy
  has_many :programme_activity_types, through: :programmes, source: :activity_types

  has_many :alerts,                                   inverse_of: :school, dependent: :destroy
  has_many :content_generation_runs,                  inverse_of: :school
  has_many :alert_generation_runs,                    inverse_of: :school
  has_many :subscription_generation_runs,             inverse_of: :school
  has_many :benchmark_result_school_generation_runs,  inverse_of: :school
  has_many :analysis_pages, through: :content_generation_runs

  has_many :low_carbon_hub_installations, inverse_of: :school

  has_many :equivalences

  has_many :locations

  has_many :simulations, inverse_of: :school, dependent: :destroy

  has_many :amr_data_feed_readings,       through: :meters
  has_many :amr_validated_readings,       through: :meters
  has_many :alert_subscription_events,    through: :contacts

  has_many :school_alert_type_exclusions

  belongs_to :calendar, optional: true
  belongs_to :template_calendar, optional: true, class_name: 'Calendar'

  belongs_to :solar_pv_tuos_area, optional: true
  belongs_to :dark_sky_area, optional: true
  belongs_to :school_group, optional: true

  has_one :school_onboarding
  has_one :configuration, class_name: 'Schools::Configuration'

  enum school_type: [:primary, :secondary, :special, :infant, :junior, :middle]

  scope :visible,       -> { where(visible: true) }
  scope :not_visible,   -> { where(visible: false) }
  scope :process_data,  -> { where(process_data: true) }
  scope :without_group, -> { where(school_group_id: nil) }

  scope :with_config, -> { joins(:configuration) }

  validates_presence_of :urn, :name, :address, :postcode, :website
  validates_uniqueness_of :urn
  validates :floor_area, :number_of_pupils, :cooks_dinners_for_other_schools_count, numericality: { greater_than: 0, allow_blank: true }
  validates :cooks_dinners_for_other_schools_count, presence: true, if: :cooks_dinners_for_other_schools?

  validates_associated :school_times, on: :school_time_update

  accepts_nested_attributes_for :school_times

  auto_strip_attributes :name, :website, :postcode, squish: true


  def latest_alert_run
    alert_generation_runs.order(created_at: :desc).first
  end

  def latest_alerts_without_exclusions
    if latest_alert_run
      latest_alert_run.alerts.without_exclusions
    else
      Alert.none
    end
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed? || postcode_changed?
  end

  # Prevent the generated urls from becoming too long
  def normalize_friendly_id(string)
    super[0..59]
  end

  # Try building a slug based on the following fields in increasing order of specificity.
  def slug_candidates
    [
      :name,
      [:postcode, :name],
      [:urn, :name]
    ]
  end

  def academic_year_for(date)
    calendar.academic_year_for(date)
  end

  def national_calendar
    calendar.based_on.based_on
  end

  def area_name
    school_group.name if school_group
  end

  def active_meters
    meters.where(active: true)
  end

  def meters_with_readings(supply = Meter.meter_types.keys)
    meters.includes(:amr_data_feed_readings).where(meter_type: supply).where.not(amr_data_feed_readings: { meter_id: nil })
  end

  def meters_with_validated_readings(supply = Meter.meter_types.keys)
    meters.includes(:amr_validated_readings).where(meter_type: supply).where.not(amr_validated_readings: { meter_id: nil })
  end

  def fuel_types
    if configuration.dual_fuel
      :electric_and_gas
    elsif configuration.has_electricity
      :electric_only
    elsif configuration.has_gas
      :gas_only
    else
      :none
    end
  end

  def has_gas?
    configuration.has_gas
  end

  def has_electricity?
    configuration.has_electricity
  end

  def analysis?
    configuration && configuration.analysis_charts.present?
  end

  def fuel_types_for_analysis
    configuration.fuel_types_for_analysis
  end

  def has_solar_pv?
    configuration.has_solar_pv
  end

  def has_storage_heaters?
    configuration.has_storage_heaters
  end

  def school_admin
    users.where(role: :school_admin)
  end

  def scoreboard
    school_group.scoreboard if school_group
  end

  def latest_content
    content_generation_runs.order(created_at: :desc).first
  end

  def latest_dashboard_alerts
    if latest_content
      latest_content.dashboard_alerts
    else
      DashboardAlert.none
    end
  end

  def authenticate_pupil(pupil_password)
    users.pupil.to_a.find {|user| user.pupil_password.casecmp?(pupil_password) }
  end

  def filterable_meters
    if has_solar_pv? || has_storage_heaters?
      Meter.none
    else
      active_meters.real
    end
  end

  def latest_management_priorities
    if latest_content
      latest_content.management_priorities
    else
      ManagementPriority.none
    end
  end

  def latest_analysis_pages
    if latest_content
      latest_content.analysis_pages
    else
      AnalysisPage.none
    end
  end

  def latest_management_dashboard_tables
    if latest_content
      latest_content.management_dashboard_tables
    else
      ManagementDashboardTable.none
    end
  end

  def latest_find_out_mores
    if latest_content
      latest_content.find_out_mores
    else
      FindOutMore.none
    end
  end

  def meter_attributes_for(meter)
    meter_attributes.where(meter_type: meter.meter_type).active
  end

  def pseudo_meter_attributes
    meter_attributes.active.select(&:pseudo?)
  end

  def school_group_pseudo_meter_attributes
    school_group ? school_group.pseudo_meter_attributes : SchoolGroupMeterAttribute.none
  end

  def all_pseudo_meter_attributes
    school_group_pseudo_meter_attributes + pseudo_meter_attributes
  end

  def pseudo_meter_attributes_to_analytics
    all_pseudo_meter_attributes.group_by(&:meter_type).inject({}) do |collection, (meter_type, attributes)|
      collection[meter_type.to_sym] = MeterAttribute.to_analytics(attributes)
      collection
    end
  end

  def meter_attributes_to_analytics
    meters.order(:mpan_mprn).inject({}) do |collection, meter|
      collection[meter.mpan_mprn] = meter.meter_attributes_to_analytics
      collection
    end
  end

  def invalidate_cache_key
    update_attribute(:validation_cache_key, SecureRandom.uuid)
  end
end

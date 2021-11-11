module Pupils
  class SchoolsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    include ActivityTypeFilterable
    include DashboardSetup
    include DashboardAlerts
    include DashboardTimeline
    include NonPublicSchools

    load_resource

    skip_before_action :authenticate_user!

    before_action only: [:show] do
      redirect_unless_permitted :show
    end

    def show
      authorize! :show_pupils_dash, @school
      @show_data_enabled_features = show_data_enabled_features?
      setup_default_features
      setup_data_enabled_features if @show_data_enabled_features
    end

  private

    def setup_default_features
      activity_setup(@school)
      @temperature_observations = @school.observations.temperature
      @show_temperature_observations = show_temperature_observations?
      @observations = setup_timeline(@school.observations)
      @default_equivalences = default_equivalences
    end

    def setup_data_enabled_features
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.pupil_dashboard, :pupil_dashboard_title, limit: 2)
      equivalence_setup(@school)
    end

    def activity_setup(school)
      @activities_count = school.activities.count
      @first = school.activities.empty?
      activity_suggester = NextActivitySuggesterWithFilter.new(school, activity_type_filter)
      @suggestion = (activity_suggester.suggest_from_programmes + activity_suggester.suggest_from_activity_history + activity_suggester.suggest_from_find_out_mores).first
    end

    def equivalence_setup(school)
      @equivalences = Equivalences::RelevantAndTimely.new(school).equivalences

      @equivalences_content = @equivalences.map do |equivalence|
        TemplateInterpolation.new(
          equivalence.content_version,
          with_objects: { equivalence_type: equivalence.content_version.equivalence_type },
        ).interpolate(
          :equivalence,
          with: equivalence.formatted_variables
        )
      end
    end

    def show_temperature_observations?
      site_settings.temperature_recording_month_numbers.include?(Time.zone.today.month)
    end

    def default_equivalences
      [
        { measure: "Last week the average school used X kWh of <strong>electricity</strong>", equivalence: "That's enough energy to boil X kettles", image_name: "kettle" },
        { measure: "Last year the average school used X kWh of <strong>gas</strong>.", equivalence: "It will take X trees, each living 40 years, to absorb the carbon dioxide released when this gas was burnt.", image_name: "tree" },
        { measure: "Last month the average school's <strong>gas</strong> use cost &\#163; X.", equivalence: "That's enough to pay for X school dinners.", image_name: "meal" },
        { measure: "Last year the average school used X kWh of <strong>gas</strong>.", equivalence: "That's the gas used by X UK homes in a year.", image_name: "house" }
      ]
    end
  end
end

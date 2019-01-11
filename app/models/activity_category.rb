# == Schema Information
#
# Table name: activity_categories
#
#  badge_name  :string
#  created_at  :datetime         not null
#  description :string
#  id          :bigint(8)        not null, primary key
#  name        :string
#  updated_at  :datetime         not null
#

class ActivityCategory < ApplicationRecord
  has_many :activity_types
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :badge_name, allow_blank: true, allow_nil: true

  def sorted_activity_types(by: :name)
    types = activity_types.where(active: true).order(by).to_a
    sort_types(types)
  end

  def sorted_activity_types_with_key_stages(by: :name, array_of_key_stages: [])
    types = activity_types.where(active: true).includes(:key_stages).where(key_stages: { id: array_of_key_stages }).order(by).to_a
    sort_types(types)
  end

private

  # Other should always be last
  def sort_types(types)
    other = types.index { |x| x.name.casecmp("other") == 0 }
    types.insert(-1, types.delete_at(other)) if other.present?
    types
  end
end

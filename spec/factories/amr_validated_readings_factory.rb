FactoryBot.define do
  factory :amr_validated_reading do
    meter
    reading_date Date.yesterday
    kwh_data_x48 { Array.new(48, rand) }
    status { 'ORIG'}
  end
end

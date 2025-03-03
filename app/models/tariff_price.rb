# == Schema Information
#
# Table name: tariff_prices
#
#  created_at           :datetime         not null
#  id                   :bigint(8)        not null, primary key
#  meter_id             :bigint(8)
#  prices               :text
#  tariff_date          :date             not null
#  tariff_import_log_id :bigint(8)
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_tariff_prices_on_meter_id                  (meter_id)
#  index_tariff_prices_on_meter_id_and_tariff_date  (meter_id,tariff_date) UNIQUE
#  index_tariff_prices_on_tariff_import_log_id      (tariff_import_log_id)
#
class TariffPrice < ApplicationRecord
  scope :by_date,       -> { order(tariff_date: :asc) }
  scope :by_date_desc,  -> { order(tariff_date: :desc) }

  belongs_to :meter, inverse_of: :tariff_prices
  belongs_to :tariff_import_log, inverse_of: :tariff_prices

  serialize :prices

  def self.delete_duplicates_for_meter!(meter)
    last_price = nil
    meter.tariff_prices.order(tariff_date: :asc).each do |tariff_price|
      last_price = tariff_price if last_price.nil? || last_price.prices != tariff_price.prices
      tariff_price.destroy if tariff_price != last_price && tariff_price.prices == last_price.prices
    end
  end
end

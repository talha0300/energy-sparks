class EnergyTariffDefaultPricesCreator
  def initialize(energy_tariff)
    @energy_tariff = energy_tariff
  end

  def process
    return if @energy_tariff.flat_rate?
    return if @energy_tariff.tariff_holder_type == 'School' && @energy_tariff.meters.empty?
    return if @energy_tariff.energy_tariff_prices.any?

    night_times = case @energy_tariff.tariff_holder_type
                  when 'School' then Economy7Times.times(@energy_tariff&.meters&.first&.mpan_mprn)
                  when 'SchoolGroup' then Economy7Times::DEFAULT_TIMES
                  when 'SiteSettings' then Economy7Times::DEFAULT_TIMES
                  end
    day_times = night_times.last..night_times.first

    @energy_tariff.energy_tariff_prices.create!(energy_tariff_price_defaults(night_times.first.to_s, night_times.last.to_s, EnergyTariffPrice::NIGHT_RATE_DESCRIPTION))
    @energy_tariff.energy_tariff_prices.create!(energy_tariff_price_defaults(day_times.first.to_s, day_times.last.to_s, EnergyTariffPrice::DAY_RATE_DESCRIPTION))
  end

  def energy_tariff_price_defaults(start_time, end_time, description)
    {
      start_time: start_time,
      end_time: end_time,
      value: 0,
      units: 'kwh',
      description: description
    }
  end
end

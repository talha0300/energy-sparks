# rubocop:disable Naming/AsciiIdentifiers
module AdvicePageHelper
  def advice_page_path(school, advice_page, tab = :insights, params: {}, anchor: nil)
    polymorphic_path([tab, school, :advice, advice_page.key.to_sym], params: params, anchor: anchor)
  end

  def sort_by_label(advice_pages)
    advice_pages.sort_by { |ap| translated_label(ap) }
  end

  def translated_label(advice_page)
    I18n.t("advice_pages.nav.pages.#{advice_page.key}")
  end

  #Helper for the advice pages, passes a scope to the I18n.t API based on
  #our naming convention and page keys. Will only work on advice pages
  #content, e.g advice_pages.*
  def advice_t(key, **vars)
    I18n.t(key, vars.merge(scope: [:advice_pages])).html_safe
  end

  def format_unit(value, units, in_table = true, user_numeric_comprehension_level = :ks2)
    FormatEnergyUnit.format(units, value, :html, false, in_table, user_numeric_comprehension_level).html_safe
  end

  def chart_start_month_year(date = Time.zone.today)
    month_year(date.last_month - 1.year)
  end

  def chart_end_month_year(date = Time.zone.today)
    month_year(date.last_month)
  end

  def month_year(date)
    I18n.t('date.month_names')[date.month] + " " + date.year.to_s
  end

  def partial_year_note(year, amr_start_date, amr_end_date)
    if year == amr_start_date.year && (amr_start_date > Date.new(year, 1, 1))
      I18n.t('advice_pages.tables.labels.partial')
    elsif year == amr_end_date.year && amr_end_date < Date.new(year, 12, 31)
      I18n.t('advice_pages.tables.labels.partial')
    else
      ''
    end
  end

  def advice_baseload_high?(estimated_savings_vs_benchmark)
    estimated_savings_vs_benchmark > 0.0
  end

  def format_rating(rating)
    rating > 4 ? "Limited variation" : "Large variation"
  end

  #link to a specific benchmark for a school group, falls back to the
  #generic benchmark page if a school doesn't have a group
  def compare_for_school_group_path(benchmark_type, school)
    if school.school_group.present?
      compare_path(benchmark: benchmark_type, school_group_ids: [school.school_group.id])
    else
      compare_path(benchmark: benchmark_type)
    end
  end

  #calculate relative % change of a current value from a base value
  def relative_percent(base, current)
    return 0.0 if base.nil? || current.nil? || base == current
    return 0.0 if base == 0.0
    (current - base) / base
  end

  def recent_data?(end_date)
    end_date > (Time.zone.today - 30.days)
  end

  def one_years_data?(start_date, end_date)
    (end_date - 364) >= start_date
  end

  def two_weeks_data?(start_date:, end_date:)
    return false unless start_date && end_date

    (end_date - start_date) >= 14
  end

  def months_analysed(start_date, end_date)
    months = months_between(start_date, end_date)
    months > 12 ? 12 : months
  end

  def months_between(start_date, end_date)
    ((end_date - start_date).to_f / 365 * 12).round
  end

  def annual_usage_breakdown_totals_for(annual_usage_breakdown, unit = :kwh)
    annual_usage_breakdown.holiday.send(unit) +
      annual_usage_breakdown.weekend.send(unit) +
      annual_usage_breakdown.school_day_open.send(unit) +
      annual_usage_breakdown.school_day_closed.send(unit) +
      annual_usage_breakdown.community.send(unit)
  end

  def meters_by_estimated_saving(meters)
    meters.sort_by {|_, v| v.estimated_saving_£.present? ? -v.estimated_saving_£ : 0.0 }
  end

  def meters_by_percentage_baseload(meters)
    meters.sort_by {|_, v| -v.percentage_baseload }
  end

  def heating_time_class(heating_start_time, recommended_time)
    return '' if heating_start_time.nil?
    if heating_start_time >= recommended_time
      'text-positive'
    else
      'text-negative'
    end
  end

  def heating_time_assessment(heating_start_time, recommended_time)
    return I18n.t('analytics.modelling.heating.no_heating') if heating_start_time.nil?
    if heating_start_time >= recommended_time
      I18n.t('analytics.modelling.heating.on_time')
    else
      I18n.t('analytics.modelling.heating.too_early')
    end
  end

  def warm_weather_on_days_adjective(rating)
    I18nHelper.adjective(rating)
  end

  def notice_status_for(rating_value)
    rating_value > 6 ? :positive : :negative
  end

  def warm_weather_on_days_status(rating)
    if [:excellent, :good].include?(rating)
      :positive
    else
      :negative
    end
  end

  def display_advice_page?(school, fuel_type)
    school_has_fuel_type?(school, fuel_type)
  end

  def school_has_fuel_type?(school, fuel_type)
    fuel_type = 'storage_heaters' if fuel_type == "storage_heater"
    fuel_type = 'electricity' if fuel_type == "solar_pv"
    school.send("has_#{fuel_type}?".to_sym)
  end

  def can_benchmark?(advice_page:)
    Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator.can_benchmark?(advice_page: advice_page)
  end

  def tariff_source(tariff_summary)
    return t('advice_pages.tables.labels.default') unless tariff_summary.real
    if tariff_summary.name.include?('DCC SMETS2')
      t('advice_pages.tables.labels.smart_meter')
    else
      t('advice_pages.tables.labels.user_supplied')
    end
  end

  def alert_types_for_group(group)
    AlertType.groups.key?(group) ? AlertType.send(group) : []
  end

  # alert type groups have a specific order here
  def dashboard_alert_groups(dashboard_alerts)
    %w[priority change benchmarking advice].select { |group| dashboard_alerts_for_group(dashboard_alerts, group).any? }
  end

  def dashboard_alerts_for_group(dashboard_alerts, group)
    dashboard_alerts.select { |dashboard_alert| dashboard_alert.alert.alert_type.group == group }
  end

  def t_weekday(week_day)
    I18n.t('date.day_names')[week_day]
  end
end
# rubocop:enable Naming/AsciiIdentifiers

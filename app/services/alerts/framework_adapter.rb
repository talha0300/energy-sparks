require 'dashboard'

module Alerts
  class FrameworkAdapter
    def initialize(alert_type, school, analysis_date, aggregate_school = AggregateSchoolService.new(school).aggregate_school)
      @alert_type = alert_type
      @school = school
      @aggregate_school = aggregate_school
      @analysis_date = analysis_date
    end

    def analyse
      analysis_obj = alert_instance.new(@aggregate_school)
      analysis_obj.analyse(@analysis_date)

      analysis_report = analysis_obj.analysis_report
      analysis_report.summary = "There was a problem running the #{@alert_type.title} alert. This is likely due to missing data." if analysis_report.summary.nil?
      build_alert(analysis_report)
    end

  private

    def alert_instance
      @alert_type.class_name.constantize
    end

    def build_alert(analysis_report)
      Alert.new(
        school_id:      @school.id,
        alert_type_id:  @alert_type.id,
        run_on:         @analysis_date,
        status:         analysis_report.status,
        summary:        analysis_report.summary,
        data:           data_hash(analysis_report),
      )
    end

    def data_hash(analysis_report)
      {
        help_url:             analysis_report.help_url,
        detail:               analysis_report.detail,
        rating:               analysis_report.rating,
      }
      # analysis_report.type is an enum from the analytics framework, describing an alert type
    end
  end
end

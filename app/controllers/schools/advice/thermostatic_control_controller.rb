module Schools
  module Advice
    class ThermostaticControlController < AdviceBaseController
      def insights
        @heating_thermostatic_analysis = build_heating_thermostatic_analysis
      end

      def analysis
        @heating_thermostatic_analysis = build_heating_thermostatic_analysis
      end

      private

      def create_analysable
        heating_thermostatic_analysis_service
      end

      def build_heating_thermostatic_analysis
        heating_thermostatic_analysis_service.create_model
      end

      def heating_thermostatic_analysis_service
        @heating_thermostatic_analysis_service ||= Heating::HeatingThermostaticAnalysisService.new(meter_collection: aggregate_school)
      end

      def set_insights_next_steps
        @advice_page_insights_next_steps = t("advice_pages.#{advice_page_key}.insights.next_steps_html").html_safe
      end

      def advice_page_key
        :thermostatic_control
      end
    end
  end
end

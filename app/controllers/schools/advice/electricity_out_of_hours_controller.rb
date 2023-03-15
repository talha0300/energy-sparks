module Schools
  module Advice
    class ElectricityOutOfHoursController < BaseOutOfHoursController
      private

      def fuel_type
        :electricity
      end

      def advice_page_key
        :electricity_out_of_hours
      end

      def aggregate_meter
        aggregate_school.aggregated_electricity_meters
      end
    end
  end
end

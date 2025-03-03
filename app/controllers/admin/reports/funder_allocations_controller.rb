module Admin
  module Reports
    class FunderAllocationsController < AdminController
      def show
      end

      def deliver
        FunderAllocationReportJob.perform_later(to: current_user.email)
        redirect_back fallback_location: admin_reports_funder_allocations_path, notice: "Funder allocation report has been sent to #{current_user.email}"
      end
    end
  end
end

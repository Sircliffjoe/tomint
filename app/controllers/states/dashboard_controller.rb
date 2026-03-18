module States
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_state_access!

    def index
      @state = current_user.state
      return redirect_to root_path, alert: "No state assigned to your account." unless @state

      @total_reports = @state.reports.count
      @pending_reports = @state.reports.where(status: :submitted).count
      @approved_reports = @state.reports.where(status: :approved).count
      @recent_reports = @state.reports.order(created_at: :desc).limit(5)
      @state_users = User.where(state: @state).count
    end

    private

    def authorize_state_access!
      unless current_user.state_admin? || current_user.state_secretary?
        redirect_to root_path, alert: "You are not authorized to access this page."
      end
    end
  end
end

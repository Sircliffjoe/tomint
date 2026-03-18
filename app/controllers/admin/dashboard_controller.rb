module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def index
      @total_users = User.count
      @total_reports = Report.count
      @pending_reports = Report.where(status: :submitted).count
      @total_states = State.count
      @total_directorates = Directorate.count
      @recent_reports = Report.order(created_at: :desc).limit(5)
    end

    private

    def authorize_admin!
      unless current_user.super_admin?
        redirect_to root_path, alert: "You are not authorized to access this page."
      end
    end
  end
end

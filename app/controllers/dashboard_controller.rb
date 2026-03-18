class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to dashboard_path_for_user
  end

  private

  def dashboard_path_for_user
    case current_user.role
    when "super_admin"
      admin_dashboard_path
    when "directorate_director"
      directorates_dashboard_path
    when "state_admin", "state_secretary"
      states_dashboard_path
    else
      reports_path
    end
  end
end

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to dashboard_path_for_current_user
  end
end

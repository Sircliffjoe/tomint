class Directorates::DashboardController < Directorates::BaseController
  def index
    @directorate = current_user.directorate
    @pending_reports = Report.where(directorate: @directorate, status: [ :submitted, :reviewed ]).count
    @recent_reports = Report.where(directorate: @directorate).order(created_at: :desc).limit(5)
  end
end

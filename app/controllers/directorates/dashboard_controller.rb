class Directorates::DashboardController < Directorates::BaseController
  def index
    @directorate = current_user.directorate
    @all_reports = Report.where(directorate: @directorate)
    @pending_reports = @all_reports.where(status: [ :submitted, :reviewed ]).count
    @recent_reports = @all_reports.order(created_at: :desc).limit(5)

    analytics = ::ReportAnalytics.new(@all_reports)
    @insights = case @directorate.name
    when "Outreaches" then analytics.outreach_insights
    when "Finance"    then analytics.finance_insights
    when "Training"   then analytics.training_insights
    when "Administration" then analytics.admin_insights
    else {}
    end
  end
end

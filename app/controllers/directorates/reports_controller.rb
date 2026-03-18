class Directorates::ReportsController < Directorates::BaseController
  before_action :set_report, only: [ :show, :review, :approve ]

  def index
    @reports = Report.where(directorate: current_user.directorate).order(created_at: :desc)
    # TODO: Add pagination and filters
  end

  def show
  end

  def review
    if @report.submitted?
      @report.reviewed!
      @report.update(reviewed_at: Time.current)
      redirect_to directorates_report_path(@report), notice: "Report marked as reviewed."
    else
      redirect_to directorates_report_path(@report), alert: "Report cannot be reviewed (current status: #{@report.status})."
    end
  end

  def approve
    if @report.reviewed? || @report.submitted?
      @report.approved!
      @report.update(approved_at: Time.current)
      redirect_to directorates_report_path(@report), notice: "Report approved."
    else
      redirect_to directorates_report_path(@report), alert: "Report cannot be approved."
    end
  end

  private

  def set_report
    @report = Report.where(directorate: current_user.directorate).find(params[:id])
  end
end

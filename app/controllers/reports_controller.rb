class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_report, only: %i[ show edit update submit destroy ]

  def index
    @reports = policy_scope(Report).order(created_at: :desc)
  end

  def show
    authorize @report
  end

  def new
    @report = Report.new
    authorize @report
  end

  def edit
    authorize @report
  end

  def create
    @report = Report.new(report_params)
    @report.user = current_user
    @report.state = current_user.state

    # Assign directorate based on category or user
    if @report.report_category&.directorate
      @report.directorate = @report.report_category.directorate
    else
      @report.directorate = current_user.directorate
    end

    authorize @report

    if @report.save
      redirect_to report_url(@report), notice: "Report was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @report
    if @report.update(report_params)
      # Re-assign directorate if category changed
      if @report.report_category&.directorate
         @report.directorate = @report.report_category.directorate
      elsif current_user.directorate
         @report.directorate = current_user.directorate
      end

      @report.save
      redirect_to report_url(@report), notice: "Report was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def submit
    authorize @report
    if @report.submitted!
      @report.update(submitted_at: Time.current)
      redirect_to report_url(@report), notice: "Report submitted successfully."
    else
      redirect_to report_url(@report), alert: "Failed to submit report."
    end
  end

  def destroy
    authorize @report
    @report.destroy
    redirect_to reports_url, notice: "Report was successfully deleted."
  end

  private
    def set_report
      @report = Report.find(params[:id])
    end

    def report_params
      params.require(:report).permit(
        :title, :body, :report_category_id,
        clubs: [ :type, :no_of_clubs, :average_attendance, :new_clubs, :compliance_programs, :compliance_report ],
        programmes: [ :type, :theme, :attendance, :first_timers, :facilitators, :cost ],
        seminars: [ :type, :lga, :trainees, :facilitators, :mobilized, :cost ],
        meetings: [ :type, :held, :avg_participants, :trainings, :others ],
        external_engagements: [ :church_based, :school, :orphanage, :ngos, :others, :total ],
        financial_summary: [ :total_income, :total_expenses, :deficit, income: [ :item, :amount ], expenses: [ :item, :amount ] ],
        others: [ :paid_membership, :ict_capability, :support_hq, :camp_report_submitted, :own_secretariat, :invitation_minister ],
        financial_report: [
          :closing_balance,
          income: [ :opening_balance, :sale_of_assets, :tithes_offerings, :camp_registration, :membership_registration, :membership_annual_levy, :trainings_seminars, :publications_books, :loans, :others, :total ],
          programme_expenses: [ :purchase_of_assets, :camp, :trainings_seminars, :end_of_year_party, :valentine, :others, :total ],
          administrative_expenses: [ :salaries_allowances, :rent, :utilities, :others, :total ],
          obligation_to_national: [ :tithes, :excess_camp_proceeds_20, :membership_registration_40, :annual_levy, :missions_missionaries, :donations, :loan_repayment, :others, :total ]
        ],
        camp_report: [
          :reporting_year, :camp_state, :camp_date, :camp_fee, :camp_venue,
          :camping_teenagers, :visiting_teenagers, :staff_volunteers, :visiting_staff,
          :cost_food, :cost_logistics, :total_attendees, :total_camp_cost,
          :teens_attending_clubs, :first_time_campers,
          :remarks, :compiled_by, :endorsed_by,
          attendance: [
            day_1: [ :am, :pm ], day_2: [ :am, :pm ], day_3: [ :am, :pm ],
            day_4: [ :am, :pm ], day_5: [ :am, :pm ], day_6: [ :am, :pm ]
          ],
          facility: [ :hall_adequate, :classrooms_adequate, :hostels_adequate, :venue_secured, :field_okay ],
          spiritual: [ :first_time_converts, :holy_spirit_baptism, :rededication, :purity_pledge ]
        ]
      )
    end
end

module ReportTemplateData
  extend ActiveSupport::Concern

  included do
    store_accessor :data, :clubs, :programmes, :seminars, :meetings, :external_engagements, :financial_summary, :financial_report, :others, :camp_report
    after_initialize :set_default_template_data, if: :new_record?
  end

  def set_default_template_data
    self.data ||= {}
    self.clubs ||= default_clubs
    self.programmes ||= default_programmes
    self.seminars ||= default_seminars
    self.meetings ||= default_meetings
    self.external_engagements ||= default_external_engagements
    self.financial_summary ||= default_financial_summary
    self.financial_report ||= default_financial_report
    self.others ||= default_others
    self.camp_report ||= default_camp_report
  end

  # Ensure sections always return default values even for existing records
  def clubs; (self.data || {})["clubs"] || default_clubs; end
  def programmes; (self.data || {})["programmes"] || default_programmes; end
  def seminars; (self.data || {})["seminars"] || default_seminars; end
  def meetings; (self.data || {})["meetings"] || default_meetings; end
  def external_engagements; (self.data || {})["external_engagements"] || default_external_engagements; end
  def financial_summary; (self.data || {})["financial_summary"] || default_financial_summary; end
  def financial_report; (self.data || {})["financial_report"] || default_financial_report; end
  def others; (self.data || {})["others"] || default_others; end
  def camp_report; (self.data || {})["camp_report"] || default_camp_report; end

  def visible_sections
    category_name = report_category&.name
    case category_name
    when "Annual Report"
      [ "clubs", "programmes", "seminars", "meetings", "external_engagements", "financial_summary", "others" ]
    when "Camp Report"
      [ "camp_report" ]
    when "Training Report"
      [ "seminars" ]
    when "Financial Report"
      [ "detailed_financial" ]
    else
      []
    end
  end

  private

  def default_clubs
    [
      { "type" => "Neighbourhood", "no_of_clubs" => 0, "average_attendance" => 0, "new_clubs" => 0, "compliance_programs" => 0, "compliance_report" => 0 },
      { "type" => "Church based", "no_of_clubs" => 0, "average_attendance" => 0, "new_clubs" => 0, "compliance_programs" => 0, "compliance_report" => 0 },
      { "type" => "School based", "no_of_clubs" => 0, "average_attendance" => 0, "new_clubs" => 0, "compliance_programs" => 0, "compliance_report" => 0 },
      { "type" => "Rural", "no_of_clubs" => 0, "average_attendance" => 0, "new_clubs" => 0, "compliance_programs" => 0, "compliance_report" => 0 },
      { "type" => "Unconventional", "no_of_clubs" => 0, "average_attendance" => 0, "new_clubs" => 0, "compliance_programs" => 0, "compliance_report" => 0 },
      { "type" => "Virtual", "no_of_clubs" => 0, "average_attendance" => 0, "new_clubs" => 0, "compliance_programs" => 0, "compliance_report" => 0 }
    ]
  end

  def default_programmes
    [
      { "type" => "Valentine's Special", "theme" => "", "attendance" => 0, "first_timers" => 0, "facilitators" => 0, "cost" => 0 },
      { "type" => "TOM Rivers Camp", "theme" => "", "attendance" => 0, "first_timers" => 0, "facilitators" => 0, "cost" => 0 },
      { "type" => "October 1st Prayers (club-based)", "theme" => "", "attendance" => 0, "first_timers" => 0, "facilitators" => 0, "cost" => 0 },
      { "type" => "End of Year Thanksgiving", "theme" => "", "attendance" => 0, "first_timers" => 0, "facilitators" => 0, "cost" => 0 }
    ]
  end

  def default_seminars
    [
      { "type" => "Club Leaders Training", "lga" => "", "trainees" => 0, "facilitators" => 0, "mobilized" => 0, "cost" => 0 },
      { "type" => "CCTM/ACCTM", "lga" => "", "trainees" => 0, "facilitators" => 0, "mobilized" => 0, "cost" => 0 },
      { "type" => "In-house Training Development", "lga" => "", "trainees" => 0, "facilitators" => 0, "mobilized" => 0, "cost" => 0 },
      { "type" => "State Workers' Retreat", "lga" => "", "trainees" => 0, "facilitators" => 0, "mobilized" => 0, "cost" => 0 }
    ]
  end

  def default_meetings
    [
      { "type" => "Statutory Nat. Meetings (RPM/NEC)", "held" => 0, "avg_participants" => 0, "trainings" => 0, "others" => "" },
      { "type" => "NTWC", "held" => 0, "avg_participants" => 0, "trainings" => 0, "others" => "" },
      { "type" => "State Workers' Meeting", "held" => 0, "avg_participants" => 0, "trainings" => 0, "others" => "" },
      { "type" => "Excos Meeting", "held" => 0, "avg_participants" => 0, "trainings" => 0, "others" => "" }
    ]
  end

  def default_external_engagements
    {
      "church_based" => 0,
      "school" => 0,
      "orphanage" => 0,
      "ngos" => 0,
      "others" => 0,
      "total" => 0
    }
  end

  def default_financial_summary
    {
      "income" => Array.new(3) { { "item" => "", "amount" => 0 } },
      "total_income" => 0,
      "expenses" => Array.new(3) { { "item" => "", "amount" => 0 } },
      "total_expenses" => 0,
      "deficit" => 0
    }
  end

  def default_others
    {
      "paid_membership" => 0,
      "ict_capability" => "",
      "support_hq" => "No",
      "camp_report_submitted" => "No",
      "own_secretariat" => "No",
      "invitation_minister" => 0
    }
  end
  def default_financial_report
    {
      "income" => {
        "opening_balance" => 0,
        "sale_of_assets" => 0,
        "tithes_offerings" => 0,
        "camp_registration" => 0,
        "membership_registration" => 0,
        "membership_annual_levy" => 0,
        "trainings_seminars" => 0,
        "publications_books" => 0,
        "loans" => 0,
        "others" => 0,
        "total" => 0
      },
      "programme_expenses" => {
        "purchase_of_assets" => 0,
        "camp" => 0,
        "trainings_seminars" => 0,
        "end_of_year_party" => 0,
        "valentine" => 0,
        "others" => 0,
        "total" => 0
      },
      "administrative_expenses" => {
        "salaries_allowances" => 0,
        "rent" => 0,
        "utilities" => 0,
        "others" => 0,
        "total" => 0
      },
      "obligation_to_national" => {
        "tithes" => 0,
        "excess_camp_proceeds_20" => 0,
        "membership_registration_40" => 0,
        "annual_levy" => 0,
        "missions_missionaries" => 0,
        "donations" => 0,
        "loan_repayment" => 0,
        "others" => 0,
        "total" => 0
      },
      "closing_balance" => 0
    }
  end

  def default_camp_report
    {
      "reporting_year" => "",
      "camp_state" => "",
      "camp_date" => "",
      "camp_fee" => 0,
      "camp_venue" => "",
      "camping_teenagers" => 0,
      "visiting_teenagers" => 0,
      "staff_volunteers" => 0,
      "visiting_staff" => 0,
      "cost_food" => 0,
      "cost_logistics" => 0,
      "attendance" => (1..6).each_with_object({}) { |d, h| h["day_#{d}"] = { "am" => 0, "pm" => 0 } },
      "teens_attending_clubs" => 0,
      "first_time_campers" => 0,
      "facility" => {
        "hall_adequate" => "Yes",
        "classrooms_adequate" => "Yes",
        "hostels_adequate" => "Yes",
        "venue_secured" => "Yes",
        "field_okay" => "Yes"
      },
      "spiritual" => {
        "first_time_converts" => 0,
        "holy_spirit_baptism" => 0,
        "rededication" => 0,
        "purity_pledge" => 0
      },
      "remarks" => "",
      "compiled_by" => "",
      "endorsed_by" => ""
    }
  end
end

module ReportTemplateData
  extend ActiveSupport::Concern

  included do
    store_accessor :data, :clubs, :programmes, :seminars, :meetings, :external_engagements, :financial_summary, :others
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
    self.others ||= default_others
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
end

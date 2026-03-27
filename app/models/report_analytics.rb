class ReportAnalytics
  def initialize(reports)
    @reports = reports
  end

  def outreach_insights
    insights = {
      total_attendance: 0,
      male: 0,
      female: 0,
      conversions: 0,
      total_cost: 0,
      food_cost: 0,
      logistics_cost: 0,
      report_count: @reports.count
    }

    @reports.each do |r|
      next unless r.data.is_a?(Hash)
      camp = r.data["camp_report"] || {}

      # Registration
      reg = camp["registration_stats"] || {}
      insights[:total_attendance] += reg["total"].to_i
      insights[:male] += reg["male"].to_i
      insights[:female] += reg["female"].to_i

      # Spiritual
      spirit = camp["spiritual_matters"] || {}
      insights[:conversions] += spirit["conversions"].to_i

      # Financials
      fin = camp["financials"] || {}
      insights[:total_cost] += fin["total_cost"].to_f
      insights[:food_cost] += fin["food_cost"].to_f
      insights[:logistics_cost] += fin["logistics_cost"].to_f
    end

    # Calculate ratios
    if insights[:total_attendance] > 0
      insights[:male_percentage] = ((insights[:male].to_f / insights[:total_attendance]) * 100).round(1)
      insights[:female_percentage] = ((insights[:female].to_f / insights[:total_attendance]) * 100).round(1)
    else
      insights[:male_percentage] = 0
      insights[:female_percentage] = 0
    end

    insights
  end

  def finance_insights
    insights = {
      total_income: 0,
      total_expense: 0,
      balance: 0,
      report_count: @reports.count
    }

    @reports.each do |r|
      next unless r.data.is_a?(Hash)
      fin = r.data["financial_report"] || {}

      income = fin["income"] || {}
      expense = fin["expenditure"] || {}

      insights[:total_income] += income["total"].to_f
      insights[:total_expense] += expense["total"].to_f
    end

    insights[:balance] = insights[:total_income] - insights[:total_expense]
    insights
  end

  def training_insights
    insights = {
      total_seminars: 0,
      total_attendance: 0,
      report_count: @reports.count
    }

    @reports.each do |r|
      next unless r.data.is_a?(Hash)
      seminars = r.data["seminars"] || []
      insights[:total_seminars] += seminars.size

      seminars.each do |s|
        insights[:total_attendance] += s["attendance"].to_i
      end
    end
    insights
  end

  def admin_insights
    insights = {
      total_clubs: 0,
      total_programmes: 0,
      total_meetings: 0,
      report_count: @reports.count
    }

    @reports.each do |r|
      next unless r.data.is_a?(Hash)
      insights[:total_clubs] += (r.data["clubs"] || []).size
      insights[:total_programmes] += (r.data["programmes"] || []).size
      insights[:total_meetings] += (r.data["meetings"] || []).size
    end
    insights
  end
end

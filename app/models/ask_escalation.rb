# frozen_string_literal: true

class AskEscalation < ApplicationRecord
  belongs_to :ask_question
  belongs_to :assigned_safeguarding_lead, class_name: "User", optional: true
  belongs_to :created_by, class_name: "User"

  enum :escalation_type, {
    safeguarding: 0,
    urgent_crisis: 1,
    abuse_report: 2,
    pastoral_critical: 3
  }

  enum :severity, {
    low: 0,
    medium: 1,
    high: 2,
    critical: 3
  }

  enum :status, {
    open: 0,
    investigating: 1,
    action_taken: 2,
    referred_external: 3,
    resolved: 4,
    closed: 5
  }

  validates :reason, presence: true

  scope :active, -> { where(status: [ :open, :investigating, :action_taken ]) }
  scope :urgent_first, -> { order(severity: :desc, created_at: :desc) }

  def severity_badge_class
    case severity
    when "critical"
      "bg-rose-600 text-white font-bold animate-pulse"
    when "high"
      "bg-amber-600 text-white font-bold"
    when "medium"
      "bg-yellow-100 text-yellow-800 border-yellow-200"
    when "low"
      "bg-gray-100 text-gray-800 border-gray-200"
    end
  end

  def status_badge_class
    case status
    when "open"
      "bg-red-100 text-red-800 border-red-200 font-semibold"
    when "investigating"
      "bg-amber-100 text-amber-800 border-amber-200 font-semibold"
    when "action_taken", "referred_external"
      "bg-blue-100 text-blue-800 border-blue-200"
    when "resolved", "closed"
      "bg-emerald-100 text-emerald-800 border-emerald-200"
    end
  end
end

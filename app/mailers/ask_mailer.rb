# frozen_string_literal: true

class AskMailer < ApplicationMailer
  def safeguarding_alert(ask_question, recipient_email)
    @question = ask_question
    @reference = ask_question.public_reference
    @priority = ask_question.priority.humanize
    @submitted_at = ask_question.submitted_at

    mail(
      to: recipient_email,
      subject: "[TOM ASK Safeguarding Alert] Attention Required: #{@reference} (#{@priority})"
    )
  end

  def question_assigned(ask_assignment)
    @assignment = ask_assignment
    @question = ask_assignment.ask_question
    @assignee = ask_assignment.assignee
    @assigned_by = ask_assignment.assigned_by

    mail(
      to: @assignee.email,
      subject: "[TOM ASK] New Question Assigned: #{@question.public_reference}"
    )
  end

  def response_published_notification(ask_question)
    @question = ask_question
    return unless ask_question.email? && ask_question.contact_details.present?

    mail(
      to: ask_question.contact_details,
      subject: "TOM ASK: Your question (#{@question.public_reference}) has been answered"
    )
  end
end

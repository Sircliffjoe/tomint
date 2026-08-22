# frozen_string_literal: true

class AskQuestionPolicy < ApplicationPolicy
  def index?
    user.present? && user.can_moderate_ask?
  end

  def show?
    return true if record.public_answer? && record.approved_public? && record.answered? && !record.safeguarding_flag?
    return false unless user.present?
    return true if user.super_admin?
    return true if record.safeguarding_flag? && user.can_access_safeguarding?
    return false if record.safeguarding_flag?

    user.can_moderate_ask? || (user.ask_responder? && record.current_assignee == user)
  end

  def create?
    true
  end

  def update?
    return false unless user.present?
    return true if user.super_admin?
    return false if record.safeguarding_flag? && !user.can_access_safeguarding?

    user.can_moderate_ask? || (user.ask_responder? && record.current_assignee == user)
  end

  def moderate?
    return false unless user.present?
    return true if user.super_admin?
    return false if record.safeguarding_flag? && !user.can_access_safeguarding?

    user.can_moderate_ask?
  end

  def assign?
    return false unless user.present?
    return true if user.super_admin?

    user.can_moderate_ask?
  end

  def destroy?
    user.present? && user.super_admin?
  end

  def safeguarding_access?
    user.present? && user.can_access_safeguarding?
  end

  class Scope < Scope
    def resolve
      if user.blank?
        scope.public_library
      elsif user.super_admin?
        scope.all
      elsif user.safeguarding_lead?
        scope.all
      elsif user.ask_moderator?
        scope.where(safeguarding_flag: false)
      elsif user.ask_responder?
        scope.where(safeguarding_flag: false).joins(:ask_assignments).where(ask_assignments: { assignee_id: user.id, active: true })
      else
        scope.public_library
      end
    end
  end
end

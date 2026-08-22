# frozen_string_literal: true

class AskQuestionPolicy < ApplicationPolicy
  def index?
    user.present? && (user.super_admin? || user.responder?)
  end

  def show?
    return true if record.public_answer? && record.approved_public? && record.answered? && !record.safeguarding_flag?
    return false unless user.present?
    return true if user.super_admin? || user.responder?

    false
  end

  def create?
    true
  end

  def update?
    return false unless user.present?
    user.super_admin? || user.responder?
  end

  def moderate?
    return false unless user.present?
    user.super_admin? || user.responder?
  end

  def assign?
    return false unless user.present?
    user.super_admin? || user.responder?
  end

  def destroy?
    user.present? && user.super_admin?
  end

  def safeguarding_access?
    user.present? && (user.super_admin? || user.responder?)
  end

  class Scope < Scope
    def resolve
      if user.blank?
        scope.public_library
      elsif user.super_admin? || user.responder?
        scope.all
      else
        scope.public_library
      end
    end
  end
end

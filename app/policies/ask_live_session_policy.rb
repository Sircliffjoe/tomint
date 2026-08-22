# frozen_string_literal: true

class AskLiveSessionPolicy < ApplicationPolicy
  def index?
    user.present? && user.can_manage_live_sessions?
  end

  def show?
    true
  end

  def display?
    true
  end

  def vote?
    true
  end

  def create?
    user.present? && user.can_manage_live_sessions?
  end

  def update?
    user.present? && (user.super_admin? || record.created_by == user || user.can_manage_live_sessions?)
  end

  def moderate?
    user.present? && (user.super_admin? || user.can_moderate_ask? || user.can_manage_live_sessions?)
  end

  def destroy?
    user.present? && (user.super_admin? || record.created_by == user)
  end

  class Scope < Scope
    def resolve
      if user.blank?
        scope.open_sessions
      elsif user.super_admin? || user.can_moderate_ask?
        scope.all
      else
        scope.open_sessions
      end
    end
  end
end

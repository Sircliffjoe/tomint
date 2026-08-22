# frozen_string_literal: true

class AskResponsePolicy < ApplicationPolicy
  def create?
    user.present? && user.can_respond_ask?
  end

  def update?
    user.present? && (user.super_admin? || record.user == user || user.can_moderate_ask?)
  end

  def publish?
    user.present? && (user.super_admin? || user.can_moderate_ask?)
  end

  def destroy?
    user.present? && (user.super_admin? || record.user == user)
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

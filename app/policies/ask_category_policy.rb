# frozen_string_literal: true

class AskCategoryPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present? && (user.super_admin? || user.can_moderate_ask?)
  end

  def update?
    user.present? && (user.super_admin? || user.can_moderate_ask?)
  end

  def destroy?
    user.present? && user.super_admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

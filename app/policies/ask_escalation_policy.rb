# frozen_string_literal: true

class AskEscalationPolicy < ApplicationPolicy
  def index?
    user.present? && user.can_access_safeguarding?
  end

  def show?
    user.present? && user.can_access_safeguarding?
  end

  def create?
    user.present? && user.can_moderate_ask?
  end

  def update?
    user.present? && user.can_access_safeguarding?
  end

  def destroy?
    user.present? && user.super_admin?
  end

  class Scope < Scope
    def resolve
      if user.present? && user.can_access_safeguarding?
        scope.all
      else
        scope.none
      end
    end
  end
end

# frozen_string_literal: true

class StatePolicy < ApplicationPolicy
  def index?
    # Allow access if user has a state-level role or higher
    user&.super_admin? || user&.directorate_director? || user&.state_admin? || user&.state_secretary?
  end

  def show?
    index?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.role.in?(%w[admin national_coordinator])
        scope.all
      elsif user&.role == "directorate_coordinator" && user&.directorate
        scope.where(directorate: user.directorate)
      elsif user&.role == "state_coordinator" && user&.state
        scope.where(id: user.state_id)
      else
        scope.none
      end
    end
  end
end

# frozen_string_literal: true

class DirectoratePolicy < ApplicationPolicy
  def index?
    # Allow access if user has a directorate-level role or is super_admin
    user&.super_admin? || user&.directorate_director?
  end

  def show?
    index?
  end

  def review?
    index?
  end

  def approve?
    index?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.role.in?(%w[admin national_coordinator])
        scope.all
      elsif user&.role == "directorate_coordinator" && user&.directorate
        scope.where(directorate: user.directorate)
      else
        scope.none
      end
    end
  end
end

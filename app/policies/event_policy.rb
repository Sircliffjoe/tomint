class EventPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.super_admin? || user&.directorate_director?
        scope.all
      elsif user&.state_admin? || user&.state_secretary?
        # Show global events (state_id: nil) OR events belonging to user's state
        scope.where(state: nil).or(scope.where(state: user.state))
      else
        # Public users see all events
        scope.all
      end
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.super_admin? || user.directorate_director? || user.state_admin?
  end

  def new?
    create?
  end

  def update?
    return false unless user

    if user.super_admin? || user.directorate_director?
      true
    elsif user.state_admin?
      # Can only update events belonging to their state
      record.state_id == user.state_id
    else
      false
    end
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end
end

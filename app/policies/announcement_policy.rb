class AnnouncementPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.super_admin? || user.directorate_director? || user.state_admin? || user.state_secretary?
  end

  def new?
    create?
  end

  def update?
    user.super_admin? || user.directorate_director? || user.state_admin? || user.state_secretary?
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end
end

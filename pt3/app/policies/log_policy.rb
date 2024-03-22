class LogPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return @user.try(:fulladmin)
  end

  def update?
    return @user.try(:fulladmin)
  end

  def destroy?
    return @user.try(:fulladmin)
  end
end

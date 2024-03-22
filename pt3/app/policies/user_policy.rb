class UserPolicy < ApplicationPolicy
  def index?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def show?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def create?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def update?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def destroy?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def edit?
    true
  end

  def change_password?
    true
  end

  def switch_organization?
    userrole_match(['AirWorthinessCert Member'])
  end

  def set_organization?
    userrole_match(['AirWorthinessCert Member'])
  end

  def email_multifactor_challenge?
    true
  end

  def text_multifactor_challenge?
    true
  end

  def security_multifactor_challenge?
    true
  end

  def switch_user?
    userrole_match(['AirWorthinessCert Member'])
  end

  def copy_user?
    userrole_match(['AirWorthinessCert Member'])
  end

  def copy_users?
    userrole_match(['AirWorthinessCert Member'])
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end

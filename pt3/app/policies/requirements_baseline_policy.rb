class RequirementsBaselinePolicy < ApplicationPolicy
  def index?
    true
  end

  def view?
    true
  end

  def show?
    true
  end

  def create?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def update?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def destroy?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end
end

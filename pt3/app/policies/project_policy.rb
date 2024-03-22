class ProjectPolicy < ApplicationPolicy
  def filter?
    true
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def update?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def destroy?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def review_status?
    true
  end
end

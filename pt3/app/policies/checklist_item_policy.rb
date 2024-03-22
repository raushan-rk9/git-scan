class ChecklistItemPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def update?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def delete?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def destroy?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end
end

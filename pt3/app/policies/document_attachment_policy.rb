class DocumentAttachmentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def update?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def destroy?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end
end
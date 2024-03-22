class PasswordPolicy < ApplicationPolicy
  def create?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end
end

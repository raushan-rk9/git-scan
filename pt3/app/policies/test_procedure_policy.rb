class TestProcedurePolicy < ApplicationPolicy
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

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Team Member'])
  end

  def export?
    userrole_match(['Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def import?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def scan_github?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def scan_gitlab?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def select_github_files?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def select_gitlab_files?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def renumber?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def mark_as_deleted?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Team Member'])
  end

  def download_file?
    true
  end

  def display_file?
    true
  end
end

class DocumentPolicy < ApplicationPolicy
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

  def upload_document?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def download_document?
    true
  end

  def document_history?
    true
  end

  def select_documents?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def package_documents?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def display_file?
    true
  end
end

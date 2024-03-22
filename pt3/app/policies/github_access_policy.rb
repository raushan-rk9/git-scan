class GithubAccessPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def update?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member'])
  end

  def destroy?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def set_repository?
    true
  end

  def set_branch?
    true
  end

  def set_folder?
    true
  end

  def get_repositories?
    true
  end

  def get_branches?
    true
  end

  def get_folders?
    true
  end

  def get_files?
    true
  end
end

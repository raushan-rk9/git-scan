class ArchivePolicy < ApplicationPolicy
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
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def destroy?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def unarchive?
    @user.present? && @user.fulladmin
  end

  def make_archives_visible?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def view?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end
end

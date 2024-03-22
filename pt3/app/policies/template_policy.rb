class TemplatePolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def update?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def delete?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def destroy?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def export?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def import?
    userrole_match(['Project Manager', 'Configuration Management'])
  end
  
  def duplicate_global_templates?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def populate_global_templates?
    userrole_match(['Project Manager'])
  end

  def mark_as_deleted?
    userrole_match(['Project Manager', 'Configuration Management', 'Team Member'])
  end
end

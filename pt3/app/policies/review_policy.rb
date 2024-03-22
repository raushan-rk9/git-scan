class ReviewPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def edit?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def create?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def update?
    return false if (@review.try(:status) == 'Closed') || Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def destroy?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end

  def cl_fill?
    return false if (@review.try(:status) == 'Closed') || Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def cl_removeall?
    return false if (@review.try(:status) == 'Closed') || Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def signin?
    true
  end

  def save_signin?
    true
  end

  def select_attendees?
    return false if (@review.try(:status) == 'Closed') || Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def sign_off?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def assign_checklists?
    return false if (@review.try(:status) == 'Closed') || Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def renumber_checklist?
    userrole_match(['Project Manager', 'Configuration Management'])
  end

  def fill_in_checklist?
    return false if (@review.try(:status) == 'Closed') || Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def submit_checklist?
    return false if (@review.try(:status) == 'Closed') || Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def consolidated_checklist?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def export_consolidated_checklist?
    userrole_match(['Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def checklist?
    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def export_checklist?
    userrole_match(['Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def import_checklist?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Quality Assurance', 'Team Member', 'Certification Representative'])
  end

  def edit_checklist?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management', 'Certification Representative' ])
  end

  def status?
    true
  end

  def close?
    return false if Project.current.try(:archive_id)

    userrole_match(['Demo User', 'Project Manager', 'Configuration Management'])
  end
end

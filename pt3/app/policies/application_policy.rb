class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  # Check if the user role is equal to the specified role.
  def userrole_equal(specified_role)
    @user.role.include?(specified_role)
  end

  # Check if the roles match any of the given roles. Roles must be passed in as an array.
  def userrole_match(specified_roles)
    return true if @user.try(:fulladmin)

    project = Project.current
    checked = false

    if project.present? # Use the project Roles
      if specified_roles.include?('Project Manager')
        project.project_managers.delete_if do |user|
          !user.present?
        end if project.project_managers.present?

        if project.project_managers.present?
          checked = true

          project.project_managers.each do |email|
            return true if email == @user.email
          end
        end
      end

      if specified_roles.include?('Configuration Management')
        project.configuration_managers.delete_if do |user|
          !user.present?
        end if project.configuration_managers.present?

        if project.configuration_managers.present?
          checked = true

          project.configuration_managers.each do |email|
            return true if email == @user.email
          end
        end
      end

      if specified_roles.include?('Quality Assurance')
        project.quality_assurance.delete_if do |user|
          !user.present?
        end if project.quality_assurance.present?

        if project.quality_assurance.present?
          checked = true

          project.quality_assurance.each do |email|
            return true if email == @user.email
          end
        end
      end

      if specified_roles.include?('Team Member')
        project.team_members.delete_if do |user|
          !user.present?
        end if project.team_members.present?

        if project.team_members.present?
          checked = true

          project.team_members.each do |email|
            return true if email == @user.email
          end
        end
      end

      if specified_roles.include?('Certification Representative')
        project.airworthiness_reps.delete_if do |user|
          !user.present?
        end if project.airworthiness_reps.present?

        if project.airworthiness_reps.present?
          checked = true

          project.airworthiness_reps.each do |email|
            return true if email == @user.email
          end
        end
      end
    end

    unless checked
      @user.role.each do |role|
        next unless role.present?

        return true if specified_roles.include?(role)
      end if @user.present?
    end

    return false
  end
end

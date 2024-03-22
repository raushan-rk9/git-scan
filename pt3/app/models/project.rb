class Project < OrganizationRecord
  has_many      :items,                  dependent: :destroy
  has_many      :problem_reports,        dependent: :destroy
  has_many      :project_accesses,       dependent: :destroy
  has_many      :system_requirements,    dependent: :destroy

  # Validations
  validates     :identifier,             presence: true, allow_blank: false
  validates     :name,                   presence: true, allow_blank: false

  # Define Roles as array types.
  serialize     :project_managers,       Array
  serialize     :configuration_managers, Array
  serialize     :quality_assurance,      Array
  serialize     :team_members,           Array
  serialize     :airworthiness_reps,     Array

  attr_accessor :users

  ACCESS_TYPES         = [
                            'PUBLIC',
                            'PRIVATE',
                            'PROTECTED'
                         ]
  PERMISSION_PRIORTIES = {
                            'OWNER'     => 4,
                            'FULL'      => 3,
                            'CHANGE'    => 2,
                            'READ ONLY' => 1
                         }

  def user_access(user = User.current)
    result                  = nil
    project_accesses          = ProjectAccess.where(project_id: id)

    unless project_accesses.present?
      result                = 'FULL' if access == 'PUBLIC' || access.nil?
    else
      if access =~ /^private$/i
        result              =  project_accesses.to_a.find { |acc| acc.user_id == user.id }
      elsif access =~ /^protected$/i
        max_priority        = 0

        project_accesses.each do |project_access|
          next unless project_access.user_id == user.id

          accesses          = project_access.access.map { |access| access.upcase }

          accesses.each do |access|
            current_priority  = PERMISSION_PRIORTIES[access]

            if    access == 'OWNER'    &&
                  (current_priority > max_priority)
              result          = access
              max_priority    = current_priority
            elsif access == 'FULL'      &&
                  (current_priority > max_priority)
              result          = access
              max_priority    = current_priority
            elsif access == 'CHANGE'    &&
                  (current_priority > max_priority)
              result          = access
              max_priority    = current_priority
            elsif access == 'READ ONLY' &&
                  (current_priority > max_priority)
              result          = access
              max_priority    = current_priority
            end
          end if accesses.present?
        end
      end
    end

    return result
  end

  def user_access?(user = User.current)
    project_access = user_access(user)

    return project_access.present?
  end

  def permitted_users
    result            = {}
    project_accesses  = ProjectAccess.where(project_id: id, organization: User.current.organization).to_a

    project_accesses.each do |access|
      user            = User.find(access.user_id)

      result[user.id] = {
                           user: user,
                           access: access.access
                        }
    end

    return result
  end

  def add_permitted_users(users, session_id)
    unless users.empty?
      users.each do |email|
        user     = User.find_by(email: email,
                                organization: User.current.organization)
        user     = User.find_by(email: email) unless user.present?

        if user.present?
          access = if user.id == User.current.id
                     [ "OWNER" ]
                   else
                     [ "FULL" ]
                   end

          project_access = ProjectAccess.new(user_id:    user.id,
                                             project_id: id,
                                             access:     access)

          DataChange.save_or_destroy_with_undo_session(project_access,
                                                       'create',
                                                       nil,
                                                       'project_accesses')
        end
      end
    end
  end

  def remove_permitted_users(sesion_id)
    project_accesses = ProjectAccess.where(project_id: id, organization: User.current.organization).to_a

    project_accesses.each do |access|
      DataChange.save_or_destroy_with_undo_session(access,
                                                   'delete',
                                                   access.id,
                                                   'project_accesses')
    end
  end

  def update_permitted_users(users, session_id)
    remove_permitted_users(session_id)
    add_permitted_users(users, session_id)
  end

  def self.current
    Thread.current[:project]
  end

  def self.current=(project)
    Thread.current[:project] = project
  end

  # Generate Item Long ID, identifier + name
  def long_id
    return self.identifier + ':' + self.name
  end

  def self.name_from_id(id)
    result  = ''
    id      = id.to_i                 if id.kind_of?(String)
    project = Project.find_by(id: id) if id.present?
    result  = project.name            if project.present?

    return result
  end

  def self.id_from_name(name, organization = User.current.organization)
    result  = nil

    return result unless name.present?

    result  = if name =~ /^\d+\.*\d*$/
                name.to_i
              else
                project = Project.find_by(name:         name,
                                          organization: organization) 

                if project.present?
                  project.id
                else
                  nil
                end
              end

    return result
  end

  def destroy(*)
    model_files = ModelFile.where(project_id: self.id)

    model_files.each do |model_file|
      sysreqs   = SystemRequirement.where(model_file_id: model_file.id)
      hlrs      = HighLevelRequirement.where(model_file_id: model_file.id)
      llrs      = LowLevelRequirement.where(model_file_id: model_file.id)
      tcs       = TestCase.where(model_file_id: model_file.id)

      sysreqs.each { |sysreq| sysreq.destroy }
      hlrs.each    { |hlr|    hlr.destroy    }
      llrs.each    { |llr|    llr.destroy    }
      tcs.each     { |tc|     tc.destroy    }

      model_file.destroy
    end

    super
  end
end

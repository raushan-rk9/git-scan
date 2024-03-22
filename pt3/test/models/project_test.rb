require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  setup do
    @project = Project.find_by(identifier: 'TEST')
    @user    = user_pm
  end

  test "Project record should be valid" do
    STDERR.puts('    Check to see that a Project Record with required fields filled in is valid.')
    assert_equals(true, @project.valid?, 'Projectt Record', '    Expect Project Record to be valid. It was valid.')
    STDERR.puts('    The Project Record was valid.')
  end

  test 'name shall be present for Project' do
    STDERR.puts('    Check to see that a project Record without a Name is invalid.')

    @project.name = nil

    assert_equals(false, @project.valid?,
                  'Project Record',
                  '    Expect Project without name not to be valid. It was not valid.')
    STDERR.puts('    The Project Record was invalid.')
  end

  test 'identifier shall be present for Project' do
    STDERR.puts('    Check to see that a project Record without an Identifier is invalid.')

    @project.identifier = nil

    assert_equals(false, @project.valid?, 'Project Record', '    Expect Project without identifier not to be valid. It was not valid.')
    STDERR.puts('    The Project Record was invalid.')
  end

  test "Create Project" do
    STDERR.puts('    Check to see that a Project can be created.')

    project = Project.new({
                            identifier:                     @project.identifier + '_001',
                            name:                           @project.name,
                            description:                    @project.description,
                            access:                         @project.access,
                            project_managers:               @project.project_managers,
                            configuration_managers:         @project.configuration_managers,
                            quality_assurance:              @project.quality_assurance,
                            team_members:                   @project.team_members,
                            airworthiness_reps:             @project.airworthiness_reps,
                            system_requirements_prefix:     @project.system_requirements_prefix,
                            high_level_requirements_prefix: @project.high_level_requirements_prefix,
                            low_level_requirements_prefix:  @project.low_level_requirements_prefix,
                            source_code_prefix:             @project.source_code_prefix,
                            test_case_prefix:               @project.test_case_prefix,
                            test_procedure_prefix:          @project.test_procedure_prefix,
                            model_file_prefix:              @project.model_file_prefix
                          })
    assert(project.save)
    STDERR.puts('    A Project was successfully created.')
  end

  test "Update Project" do
    STDERR.puts('    Check to see that a Project can be updated.')
    identifier           = @project.identifier.dup    
    @project.identifier += '_001'

    assert(@project.save)

    @project.identifier = identifier
    STDERR.puts('    A Project was successfully updated.')
  end

  test "Delete Project" do
    STDERR.puts('    Check to see that a Project can be deleted.')
    assert(@project.destroy)
    STDERR.puts('    A Project was successfully deleted.')
  end

  test "Undo/Redo Create Project" do
    STDERR.puts('    Check to see that a Project can be created, then undone and then redone.')

    project = Project.new({
                            identifier:                     @project.identifier + '_001',
                            name:                           @project.name,
                            description:                    @project.description,
                            access:                         @project.access,
                            project_managers:               @project.project_managers,
                            configuration_managers:         @project.configuration_managers,
                            quality_assurance:              @project.quality_assurance,
                            team_members:                   @project.team_members,
                            airworthiness_reps:             @project.airworthiness_reps,
                            system_requirements_prefix:     @project.system_requirements_prefix,
                            high_level_requirements_prefix: @project.high_level_requirements_prefix,
                            low_level_requirements_prefix:  @project.low_level_requirements_prefix,
                            source_code_prefix:             @project.source_code_prefix,
                            test_case_prefix:               @project.test_case_prefix,
                            test_procedure_prefix:          @project.test_procedure_prefix,
                            model_file_prefix:              @project.model_file_prefix
                          })

    data_change = DataChange.save_or_destroy_with_undo_session(project, 'create')

    assert_not_nil(data_change)

    assert_difference('Project.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('Project.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end
    STDERR.puts('    A Project was successfully created, then undone and then redone.')
  end

  test "Undo/Redo Update Project" do
    STDERR.puts('    Check to see that a Project can be updated, then undone and then redone.')

    identifier           = @project.identifier.dup    
    @project.identifier += '_001'

    data_change = DataChange.save_or_destroy_with_undo_session(@project, 'update')

    @project.identifier = identifier

    assert_not_nil(data_change)
    assert_not_nil(Project.find_by(identifier: @project.identifier + '_001'))
    assert_nil(Project.find_by(identifier: @project.identifier))

    ChangeSession.undo(data_change.session_id)
    assert_nil(Project.find_by(identifier: @project.identifier + '_001'))
    assert_not_nil(Project.find_by(identifier: @project.identifier))

    ChangeSession.redo(data_change.session_id)
    assert_not_nil(Project.find_by(identifier: @project.identifier + '_001'))
    assert_nil(Project.find_by(identifier: @project.identifier))
    STDERR.puts('    A Project was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete Project" do
    STDERR.puts('    Check to see that a Project can be deleted, then undone and then redone.')
    data_change = DataChange.save_or_destroy_with_undo_session(@project, 'delete')

    assert_not_nil(data_change)
    assert_nil(Project.find_by(identifier: @project.identifier))

    ChangeSession.undo(data_change.session_id)
    assert_not_nil(Project.find_by(identifier: @project.identifier))

    ChangeSession.redo(data_change.session_id)
    assert_nil(Project.find_by(identifier: @project.identifier))
    STDERR.puts('    A Project was successfully deleted, then undone and then redone.')
  end
  
  test 'User Access' do
    STDERR.puts('    Check to see that a Project can return user access properly.')
    @project.add_permitted_users([ @user.email ], nil)

    user            = User.find_by(email: 'test_2@airworthinesscert.com')
    @project.access = 'protected'

    @project.save!

    permitted_users = @project.permitted_users
    user_access     = @project.user_access(@user)

    assert_equals(['FULL'], permitted_users[@user.id][:access], 'User Access',
                  '    Expect User Access to be FULL. It was.')
    assert_equals("FULL", user_access, 'User Access',
                  '    Expect User Access to be FULL. It was.')
    assert_equals(true, @project.user_access?(@user), 'User Access',
                  '    Expect user_access? to be True. It was.')
    @project.update_permitted_users([ @user.email, user.email ], nil)
    assert_equals("FULL", @project.user_access(user), 'User Access',
                  '    Expect User Access to be FULL. It was.')
    STDERR.puts('    A Project returned user access properly.')
  end

  test 'name_from_id' do
    STDERR.puts('    Check to see that a Project returns the Name from an ID.')
    assert_equals('Test', Project.name_from_id(@project.id), 'Project Name',
                  "    Expect full_id_from_id to be Test. It was.")
    STDERR.puts('    The Project successfully returned the Name from an ID.')
  end

  test 'id_from_name' do
    STDERR.puts('    Check to see that a Project returns the ID from Name.')
    assert_equals(@project.id, Project.id_from_name('Test'), 'Project ID',
                  "    Expect id_from_name to be #{@project.id}. It was.")
    STDERR.puts('    The Project successfully returned the ID from Name.')
  end
end

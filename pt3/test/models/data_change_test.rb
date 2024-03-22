require 'test_helper'

class DataChangeTest < ActiveSupport::TestCase
  def setup
    @project = Project.find_by(identifier: 'TEST')

    assert @project.present?
  end

  test "Add New Data Change For Poject Create" do
    STDERR.puts('    Check to see that a Data Change can be created for a Project Create.')

    @data_change = DataChange.record_change('projects', 'create', @project.id,
                                            @project)

    assert @data_change.present?
    assert @data_change.valid?
    @data_change.save!

    @data_change = DataChange.find(@data_change.id)

    assert @data_change.present?

    @data_change.destroy
    STDERR.puts('    A Data Change was successfully created for a Project Create.')
  end

  test "Add New Data Change For Project Update" do
    STDERR.puts('    Check to see that a Data Change can be created for a Project Update.')

    @data_change = DataChange.record_change('projects', 'update', @project.id,
                                            @project)

    assert @data_change.present?
    assert @data_change.valid?
    @data_change.save!

    @data_change = DataChange.find(@data_change.id)

    assert @data_change.present?

    @data_change.destroy
    STDERR.puts('    A Data Change was successfully created for a Project Update.')
  end

  test "Add New Data Change For Delete Create" do
    STDERR.puts('    Check to see that a Data Change can be created for a Project Delete.')

    @data_change = DataChange.record_change('projects', 'delete', @project.id,
                                            @project)

    assert @data_change.present?
    assert @data_change.valid?
    @data_change.save!

    @data_change = DataChange.find(@data_change.id)

    assert @data_change.present?

    @data_change.destroy
    STDERR.puts('    A Data Change was successfully created for a Project Delete.')
  end

  test "Undo/Redo Create Project" do
    STDERR.puts('    Check to see that an Project can be created, then undone and then redone.')

    project     = Project.new({
                                 identifier:                     'TEST_2',
                                 name:                           'Test 2',
                                 description:                    'Second Test Project',
                                 sysreq_count:                   0,
                                 pr_count:                       0,
                                 access:                         'public',
                                 organization:                   'test',
                                 project_managers:               ['test_1@airworthinesscert.com'],
                                 configuration_managers:         ['test_2@airworthinesscert.com'],
                                 quality_assurance:              ['test_3@airworthinesscert.com'],
                                 team_members:                   ['test_4@airworthinesscert.com'],
                                 airworthiness_reps:             ['test_5@airworthinesscert.com'],
                                 system_requirements_prefix:     'SYS',
                                 high_level_requirements_prefix: 'HLR',
                                 low_level_requirements_prefix:  'LLR',
                                 source_code_prefix:             'SC',
                                 test_case_prefix:               'TC',
                                 test_procedure_prefix:          'TP',
                                 model_file_prefix:              'MF'
                              })
    data_change = DataChange.save_or_destroy_with_undo_session(project,
                                                               'create')

    assert_not_nil(data_change)
    assert_not_nil(Project.find_by(identifier: project.identifier))

    assert_difference('Project.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_not_nil(Project.find_by(identifier: @project.identifier))
    assert_nil(Project.find_by(identifier: project.identifier))

    assert_difference('Project.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    assert_not_nil(Project.find_by(identifier: project.identifier))

    STDERR.puts('    A Project was successfully created, then undone and then redone.')
  end

  test "Undo/Redo Update Project" do
    STDERR.puts('    Check to see that a Project can be updated, then undone and then redone.')

    identifier                      = @project.identifier.dup
    @project.identifier             = 'TEST_2'

    data_change = DataChange.save_or_destroy_with_undo_session(@project,
                                                               'update')

    assert_not_nil(data_change)
    assert_not_nil(Project.find_by(identifier: @project.identifier))
    assert_nil(Project.find_by(identifier: identifier))
    ChangeSession.undo(data_change.session_id)
    assert_nil(Project.find_by(identifier: @project.identifier))
    assert_not_nil(Project.find_by(identifier: identifier))
    ChangeSession.redo(data_change.session_id)
    assert_not_nil(Project.find_by(identifier: @project.identifier))
    assert_nil(Project.find_by(identifier: identifier))
    STDERR.puts('    A Project was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete Project" do
    STDERR.puts('    Check to see that a Project can be deleted undone and redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@project,
                                                               'delete')

    assert_not_nil(data_change)
    assert_nil(Project.find_by(identifier: @project.identifier))
    ChangeSession.undo(data_change.session_id)
    assert_not_nil(Project.find_by(identifier: @project.identifier))
    ChangeSession.redo(data_change.session_id)
    assert_nil(Project.find_by(identifier: @project.identifier))
    STDERR.puts('    A Project was successfully deleted undone and redone.')
  end
end

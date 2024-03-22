require 'test_helper'

class ProblemReportHistoryTest < ActiveSupport::TestCase
  def setup
    @project                = Project.find_by(identifier: 'TEST')
    @hardware_item          = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item          = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @problem_report         = ProblemReport.find_by(prid: 3)
    @problem_report_history = ProblemReportHistory.find_by(problem_report_id: @problem_report.id)

    user_pm
  end

  test 'Problem Report History record should be valid' do
    STDERR.puts('    Check to see that a Problem Report History Record with required fields filled in is valid.')
    assert_equals(true, @problem_report_history.valid?,
                  'Problem Report History Record',
                  '    Expect Problem Report History Record to be valid. It was valid.')
    STDERR.puts('    The Problem Report History Record was valid.')
  end

  test 'project id shall be present for Problem Report History' do
    STDERR.puts('    Check to see that a Problem Report History Record without a Project ID is invalid.')

    @problem_report_history.project_id = nil

    assert_equals(false, @problem_report_history.valid?,
                  'Problem Report History Record',
                  '    Expect Project without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Problem Report History Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Problem Report History' do
    STDERR.puts('    Check to see that an Problem Report History can be created.')

    problem_report_history = ProblemReportHistory.new({
                                                         action:            @problem_report_history.action,
                                                         modifiedby:        @problem_report_history.modifiedby,
                                                         status:            @problem_report_history.status,
                                                         datemodified:      @problem_report_history.datemodified,
                                                         project_id:        @problem_report_history.project_id,
                                                         problem_report_id: @problem_report_history.problem_report_id,
                                                         severity_type:     @problem_report_history.severity_type
                                                      })

    assert_not_equals_nil(problem_report_history.save,
                          'Problem Report History Record',
                          '    Expect Problem Report History Record to be created. It was.')
    STDERR.puts('    A Problem Report History was successfully created.')
  end

  test 'should update Problem Report History' do
    STDERR.puts('    Check to see that an Problem Report History can be updated.')

    @problem_report_history.action = 'Update Problem Report'
    @problem_report_history.status = 'Implemented'

    assert_not_equals_nil(@problem_report_history.save, 'Problem Report History Record',
                          '    Expect Problem Report History Record to be updated. It was.')
    STDERR.puts('    A Problem Report History was successfully updated.')
  end

  test 'should delete Problem Report History' do
    STDERR.puts('    Check to see that an Problem Report History can be deleted.')
    assert( @problem_report_history.destroy)
    STDERR.puts('    A Problem Report History was successfully deleted.')
  end

  test 'should create Problem Report History with undo/redo' do
    STDERR.puts('    Check to see that an Problem Report History can be created, then undone and then redone.')

    problem_report_history = ProblemReportHistory.new({
                                                         action:            @problem_report_history.action,
                                                         modifiedby:        @problem_report_history.modifiedby,
                                                         status:            @problem_report_history.status,
                                                         datemodified:      @problem_report_history.datemodified,
                                                         project_id:        @problem_report_history.project_id,
                                                         problem_report_id: @problem_report_history.problem_report_id,
                                                         severity_type:     @problem_report_history.severity_type
                                                      })
    data_change            = DataChange.save_or_destroy_with_undo_session(problem_report_history, 'create')

    assert_not_equals_nil(data_change, 'Problem Report History Record', '    Expect Problem Report History Record to be created. It was.')

    assert_difference('ProblemReportHistory.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('ProblemReportHistory.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end
    STDERR.puts('    A Problem Report History was successfully created, then undone and then redone.')
  end

  test 'should update Problem Report History with undo/redo' do
    STDERR.puts('    Check to see that an Problem Report History can be updated, then undone and then redone.')

    @problem_report_history.action  = 'Update Problem Report'
    @problem_report_history.status  = 'Implemented'
    data_change                     = DataChange.save_or_destroy_with_undo_session(@problem_report_history, 'update')

    assert_not_equals_nil(data_change, 'Problem Report History Record',
                          '    Expect Problem Report History Record to be updated. It was')
    assert_not_equals_nil(ProblemReportHistory.find_by(action: 'Update Problem Report',
                                                       problem_report_id: @problem_report.id),
                          'Problem Report History Record',
                          "    Expect Problem Report to be updated. It was.")
    assert_equals(nil, ProblemReportHistory.find_by(action: 'Create Problem Report',
                                                    problem_report_id: @problem_report.id),
                  'Problem Report History Record',
                  '    Expect original Problem Report History Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, ProblemReportHistory.find_by(action: 'Update Problem Report',
                                                    problem_report_id: @problem_report.id),
                  'Problem Report History Record',
                  "    Expect updated Problem Report History's Record not to found. It was not found.")
    assert_not_equals_nil(ProblemReportHistory.find_by(action: 'Create Problem Report',
                                                       problem_report_id: @problem_report.id),
                          'Problem Report History Record',
                          '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(ProblemReportHistory.find_by(action: 'Update Problem Report',
                                                       problem_report_id: @problem_report.id),
                          'Problem Report History Record',
                          "    Expect updated Problem Report History's Record to be found. It was found.")
    assert_equals(nil, ProblemReportHistory.find_by(action: 'Create Problem Report',
                                                    problem_report_id: @problem_report.id),
                  'Problem Report History Record',
                  '    Expect Orginal Record not to be found. It was not found.')

    STDERR.puts('    A Problem Report History was successfully updated, then undone and then redone.')
  end

  test 'should delete Problem Report History with undo/redo' do
    STDERR.puts('    Check to see that a Problem Report History can be deleted undone and redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@problem_report_history,
                                                               'delete')

    assert_not_equals_nil(data_change, 'Problem Report History Record',
                          '    Expect that the delete succeded. It did.')
    assert_equals(nil, ProblemReportHistory.find_by(problem_report_id: @problem_report.id),
                        'Problem Report History Record',
                        '    Verify that the Problem Report History Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(ProblemReportHistory.find_by(problem_report_id: @problem_report.id),
                          'Problem Report History Record',
                          '    Verify that the Problem Report History Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, ProblemReportHistory.find_by(problem_report_id: @problem_report.id),
                  'Problem Report History Record',
                  '    Verify that the Problem Report History Record was deleted again after redo. It was.')

    STDERR.puts('    A Problem Report History was successfully deleted undone and redone.')
  end
end

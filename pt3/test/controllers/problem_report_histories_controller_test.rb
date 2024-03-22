require 'test_helper'

class ProblemReportHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project                = Project.find_by(identifier: 'TEST')
    @hardware_item          = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item          = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @problem_report         = ProblemReport.find_by(prid: 3)
    @problem_report_history = ProblemReportHistory.find_by(problem_report_id: @problem_report.id)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that a Problem Report History List can be viewed.')
    get problem_report_problem_report_histories_url(@problem_report)
    assert_response :success
    STDERR.puts('    A Problem Report History List was viewed successfully.')
  end

  test "should show problem_report_history" do
    STDERR.puts('    Check to see that a Problem Report History can be viewed.')
    get problem_report_problem_report_history_url(@problem_report,
                                                  @problem_report_history)
    assert_response :success
    STDERR.puts('    A Problem Report History was viewed successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Problem Report History Page can be loaded.')
    get new_problem_report_problem_report_history_url(@problem_report)
    assert_response :success
    STDERR.puts('    A new Problem Report History Page was loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a edit Problem Report History Page can be loaded.')
    get edit_problem_report_problem_report_history_url(@problem_report,
                                                       @problem_report_history)
    assert_response :success
    STDERR.puts('    A edit Problem Report History Page was loaded successfully.')
  end

  test "should create problem_report_history" do
    STDERR.puts('    Check to see that a Problem Report History can be created.')
    assert_difference('ProblemReportHistory.count') do
      post problem_report_problem_report_histories_url(@problem_report),
        params:
        {
          problem_report_history:
          {
            action:            @problem_report_history.action,
            modifiedby:        @problem_report_history.modifiedby,
            status:            @problem_report_history.status,
            datemodified:      @problem_report_history.datemodified,
            project_id:        @problem_report_history.project_id,
            problem_report_id: @problem_report_history.problem_report_id,
            severity_type:     @problem_report_history.severity_type
          }
        }
    end

    assert_redirected_to problem_report_problem_report_history_url(@problem_report,
                                                                   ProblemReportHistory.last)
    STDERR.puts('    A Problem Report History was created successfully.')
  end

  test "should update problem_report_history" do
    STDERR.puts('    Check to see that a Problem Report History can be updated.')
    patch problem_report_problem_report_history_url(@problem_report,
                                                    @problem_report_history),
      params:
      {
        problem_report_history:
        {
          action:            @problem_report_history.action,
          modifiedby:        @problem_report_history.modifiedby,
          status:            @problem_report_history.status,
          datemodified:      @problem_report_history.datemodified,
          project_id:        @problem_report_history.project_id,
          problem_report_id: @problem_report_history.problem_report_id,
          severity_type:     @problem_report_history.severity_type
        }
      }

    assert_redirected_to problem_report_problem_report_history_url(@problem_report,
                                                                   @problem_report_history)
    STDERR.puts('    A Problem Report History was updated successfully.')
  end

  test "should destroy problem_report_history" do
    STDERR.puts('    Check to see that a Problem Report History can be deleted.')
    assert_difference('ProblemReportHistory.count', -1) do
      delete problem_report_problem_report_history_url(@problem_report,
                                                       @problem_report_history)
    end

    assert_redirected_to problem_report_problem_report_histories_url(@problem_report)
    STDERR.puts('    A Problem Report History was deleted successfully.')
  end
end

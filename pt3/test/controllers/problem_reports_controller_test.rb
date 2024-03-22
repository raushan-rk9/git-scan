require 'test_helper'

class ProblemReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project        = Project.find_by(identifier: 'TEST')
    @problem_report = ProblemReport.find_by(prid: 3)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Problem Reports List Page can be loaded.')
    get project_problem_reports_url(@project)
    assert_response :success
    STDERR.puts('    The Problem Reports List Page loaded successfully.')
  end

  test "should get filtered index" do
    STDERR.puts('    Check to see that the Filtered Problem Reports List Page can be loaded.')
    get project_filtered_problem_reports_url(@project)
    assert_response :success
    STDERR.puts('    The Filtered Problem Reports List Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the New Problem Report Page can be loaded.')
    get new_project_problem_report_url(@project)
    assert_response :success
    STDERR.puts('    The New Problem Reports Page loaded successfully.')
  end

  test "should create problem_report" do
    STDERR.puts('    Check to see that a New Problem Report can be created.')
    assert_difference('ProblemReport.count') do
      post project_problem_reports_url(@project),
        params:
        {
           problem_report:
           {
              project_id:          @problem_report.project_id,
              item_id:             @problem_report.item_id,
              prid:                @problem_report.prid + 3,
              dateopened:          @problem_report.dateopened,
              status:              @problem_report.status,
              openedby:            @problem_report.openedby,
              title:               @problem_report.title,
              product:             @problem_report.product,
              criticality:         @problem_report.criticality,
              source:              @problem_report.source,
              discipline_assigned: @problem_report.discipline_assigned,
              assignedto:          @problem_report.assignedto,
              target_date:         @problem_report.target_date,
              close_date:          @problem_report.close_date,
              description:         @problem_report.description,
              problemfoundin:      @problem_report.problemfoundin,
              correctiveaction:    @problem_report.correctiveaction,
              fixed_in:            @problem_report.fixed_in,
              verification:        @problem_report.verification,
              feedback:            @problem_report.feedback,
              notes:               @problem_report.notes,
              meeting_id:          @problem_report.meeting_id,
              safetyrelated:       @problem_report.safetyrelated,
              datemodified:        @problem_report.datemodified
           }
        }

    end

    assert_redirected_to project_problem_report_url(@project, ProblemReport.last)
    STDERR.puts('    A New Problem Reports was successfully created.')
  end

  test "should show problem_report" do
    STDERR.puts('    Check to see that the Problem Report can be shown.')
    get project_problem_report_url(@project, @problem_report)
    assert_response :success
    STDERR.puts('    The Problem Reports was successfully viewed.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the Problem Reports Edit Page can be loaded.')
    get edit_project_problem_report_url(@project, @problem_report)
    assert_response :success
    STDERR.puts('    The Problem Reports Edit Page loaded successfully.')
  end

  test "should update problem_report" do
    STDERR.puts('    Check to see that a New Problem Report can be updated.')
    patch project_problem_report_url(@project, @problem_report),
      params:
      {
         problem_report:
         {
            project_id:          @problem_report.project_id,
            item_id:             @problem_report.item_id,
            prid:                @problem_report.prid + 3,
            dateopened:          @problem_report.dateopened,
            status:              @problem_report.status,
            openedby:            @problem_report.openedby,
            title:               @problem_report.title,
            product:             @problem_report.product,
            criticality:         @problem_report.criticality,
            source:              @problem_report.source,
            discipline_assigned: @problem_report.discipline_assigned,
            assignedto:          @problem_report.assignedto,
            target_date:         @problem_report.target_date,
            close_date:          @problem_report.close_date,
            description:         @problem_report.description,
            problemfoundin:      @problem_report.problemfoundin,
            correctiveaction:    @problem_report.correctiveaction,
            fixed_in:            @problem_report.fixed_in,
            verification:        @problem_report.verification,
            feedback:            @problem_report.feedback,
            notes:               @problem_report.notes,
            meeting_id:          @problem_report.meeting_id,
            safetyrelated:       @problem_report.safetyrelated,
            datemodified:        @problem_report.datemodified
         }
      }

    assert_redirected_to project_problem_report_url(@project, @problem_report)
    STDERR.puts('    A New Problem Reports was successfully updated.')
  end

  test "should destroy problem_report" do
    STDERR.puts('    Check to see that a New Problem Report can be deleted.')

    assert_difference('ProblemReport.count', -1) do
      delete project_problem_report_url(@project, @problem_report)
    end

    assert_redirected_to project_problem_reports_url(@project)
    STDERR.puts('    A New Problem Reports was successfully deleted.')
  end

  test "should export problem reports" do
    STDERR.puts('    Check to see that a Problem Report can be exported.')
    get project_problem_reports_export_url(@project)
    assert_response :success

    post project_problem_reports_export_url(@project),
      params:
      {
        pr_export:
        {
          export_type: 'CSV'
        }
      }

    assert_redirected_to project_problem_reports_export_path(@project, :format => :csv)
    get project_problem_reports_export_url(@project, :format => :csv)
    assert_response :success

    lines = response.body.split("\n")

    assert_equals('item_id,prid,dateopened,status,openedby,title,product,criticality,source,discipline_assigned,assignedto,target_date,close_date,description,problemfoundin,correctiveaction,fixed_in,verification,feedback,notes,meeting_id,safetyrelated,datemodified,archive_id,referenced_artifacts',
                  lines[0], 'Header',
                  '    Expect header to be "item_id,prid,dateopened,status,openedby,title,product,criticality,source,discipline_assigned,assignedto,target_date,close_date,description,problemfoundin,correctiveaction,fixed_in,verification,feedback,notes,meeting_id,safetyrelated,datemodified,archive_id,referenced_artifacts". It was.')

    get project_problem_reports_export_url(@project)
    assert_response :success

    post project_problem_reports_export_url(@project),
      params:
      {
        pr_export:
        {
          export_type: 'PDF'
        }
      }

    assert_redirected_to project_problem_reports_export_path(@project, :format => :pdf)
    get project_problem_reports_export_url(@project, :format => :pdf)
    assert_response :success
    assert_between(29000, 34000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 29000 and 34000.")
    get project_problem_reports_export_url(@project)
    assert_response :success

    post project_problem_reports_export_url(@project),
      params:
      {
        pr_export:
        {
          export_type: 'XLS'
        }
      }

    assert_redirected_to project_problem_reports_export_path(@project, :format => :xls)
    get project_problem_reports_export_url(@project, :format => :xls)
    assert_response :success
    assert_equals(true, ((response.body.length > 6000) && (response.body.length < 7000)), 'XLS Download Length', "    Expect XLS download length to be > 6000. It was...")
    get project_problem_reports_export_url(@project)
    assert_response :success

    post project_problem_reports_export_url(@project),
      params:
      {
        pr_export:
        {
          export_type: 'HTML'
        }
      }

    assert_response :success
    STDERR.puts('    A Problem Report was exported.')
  end

  test "should get import" do
    STDERR.puts('    Check to see that a Problem Report file can be imported.')

    post project_problem_reports_import_url(@project),
      params:
      {
        '/import' =>
        {
          project_select:               @project.id,
          duplicates_permitted:          '1',
          file:                          fixture_file_upload('files/Test-Problem_Reports.csv')
        }
      }

    assert_redirected_to project_problem_reports_path(@project)
    STDERR.puts('    A Problem Report file was imported.')
  end
end

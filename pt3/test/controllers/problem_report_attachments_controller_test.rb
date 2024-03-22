require 'test_helper'

class ProblemReportAttachmentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project                   = Project.find_by(identifier: 'TEST')
    @hardware_item             = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item             = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @problem_report            = ProblemReport.find_by(prid: 2)
    @problem_report_attachment = ProblemReportAttachment.find_by(problem_report_id: @problem_report.id)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Problem Report Attachment List Page can be loaded.')
    get problem_report_problem_report_attachments_url(@problem_report)
    assert_response :success
    STDERR.puts('    The Problem Report Attachment List Page loaded successfully.')
  end

  test "should show problem_report_attachment" do
    STDERR.puts('    Check to see that a Problem Report Attachment Page can be viewed.')
    get problem_report_problem_report_attachment_url(@problem_report, @problem_report_attachment)
    assert_response :success
    STDERR.puts('    A Problem Report Attachment Page was viewed successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Problem Report Attachment Page can be loaded.')
    get new_problem_report_problem_report_attachment_url(@problem_report)
    assert_response :success
    STDERR.puts('    A new Problem Report Attachment Page was loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a edit Problem Report Attachment Page can be loaded.')
    get edit_problem_report_problem_report_attachment_url(@problem_report, @problem_report_attachment)
    assert_response :success
    STDERR.puts('    A edit Problem Report Attachment Page was loaded successfully.')
  end

  test "should create problem_report_attachment" do
    STDERR.puts('    Check to see that a Problem Report Attachment Page can be created.')

    assert_difference('ProblemReportAttachment.count') do
      post problem_report_problem_report_attachments_url(@problem_report),
        params:
        {
          problem_report_attachment:
          {
             problem_report_id: @problem_report_attachment.problem_report_id,
             project_id:        @problem_report_attachment.project_id,
             item_id:           @hardware_item.id,
             user:              @problem_report_attachment.user,
             organization:      @problem_report_attachment.organization,
             link_type:         @problem_report_attachment.link_type,
             link_description:  @problem_report_attachment.link_description,
             link_link:         @problem_report_attachment.link_link,
             upload_date:       @problem_report_attachment.upload_date
          }
        }
    end

    assert_redirected_to problem_report_problem_report_attachments_url(@problem_report)
    STDERR.puts('    A Problem Report Attachment Page was created successfully.')
  end

  test "should update problem_report_attachment" do
    STDERR.puts('    Check to see that a Problem Report Attachment Page can be updated.')

    patch problem_report_problem_report_attachment_url(@problem_report,
                                                       @problem_report_attachment),
      params:
      {
        problem_report_attachment:
        {
           problem_report_id: @problem_report_attachment.problem_report_id,
           project_id:        @problem_report_attachment.project_id,
           item_id:           @hardware_item.id,
           user:              @problem_report_attachment.user,
           organization:      @problem_report_attachment.organization,
           link_type:         @problem_report_attachment.link_type,
           link_description:  @problem_report_attachment.link_description,
           link_link:         @problem_report_attachment.link_link,
           upload_date:       @problem_report_attachment.upload_date
        }
      }

    assert_redirected_to problem_report_problem_report_attachment_url(@problem_report, @problem_report_attachment)
    STDERR.puts('    A Problem Report Attachment Page was updated successfully.')
  end

  test "should destroy problem_report_attachment" do
    STDERR.puts('    Check to see that a Problem Report Attachment Page can be deleted.')

    assert_difference('ProblemReportAttachment.count', -1) do
      delete problem_report_problem_report_attachment_url(@problem_report, @problem_report_attachment)
    end

    assert_redirected_to problem_report_problem_report_attachments_url(@problem_report)
    STDERR.puts('    A Problem Report Attachment Page was deleted successfully.')
  end
end

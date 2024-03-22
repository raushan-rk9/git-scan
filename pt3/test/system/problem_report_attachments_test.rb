require "application_system_test_case"

class ProblemReportAttachmentsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  def setup
    @project                   = Project.find_by(identifier: 'TEST')
    @hardware_item             = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item             = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @problem_report            = ProblemReport.find_by(prid: 2)
    @problem_report_attachment = ProblemReportAttachment.find_by(problem_report_id: @problem_report.id)

    user_pm
  end

  test "visiting the index" do
    STDERR.puts('    Check to see that the Problem Report Attachment List Page can be loaded.')
    visit problem_report_problem_report_attachments_url(@problem_report)
    assert_selector "h1", text: "Problem Report Attachments"
    STDERR.puts('    The Problem Report Attachments  List loaded successfully.')
  end

  test 'should show problem report attachment' do
    STDERR.puts('    Check to see that the problem report attachment view Page can be loaded.')
    visit problem_report_problem_report_attachments_url(@problem_report)
    assert_selector "h1", text: "Problem Report Attachments"
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Problem Report:'
    STDERR.puts('    The problem report attachment view Page was loaded.')
  end

  test "creating a Problem report attachment" do
    STDERR.puts('    Check to see that the problem report attachment view Page can be created.')
    visit problem_report_problem_report_attachments_url(@problem_report)
    click_on "New Problem Report Attachment"
    assert_selector "h1", text: "New Problem Report Attachment"
    select('File Upload', from: 'problem_report_attachment_link_type')
    attach_file("problem_report_attachment_file", Rails.root + "test/fixtures/files/flowchart.png")
    click_on "Create Problem report attachment"

    assert_text "Problem Report attachment was successfully created."
    STDERR.puts('    The problem report attachment was created successfully.')
  end

  test "updating a Problem report attachment" do
    STDERR.puts('    Check to see that the problem report attachment view Page can be updated.')
    visit problem_report_problem_report_attachments_url(@problem_report)
    click_on "Edit", match: :first
    assert_selector "h1", text: "Editing Problem Report Attachment"
    select('File Upload', from: 'problem_report_attachment_link_type')
    attach_file("problem_report_attachment_file", Rails.root + "test/fixtures/files/flowchart.png")
    click_on "Update Problem report attachment"

    assert_text "Problem Report attachment was successfully updated."
    STDERR.puts('    The problem report attachment was updated successfully.')
  end

  test "destroying a Problem report attachment" do
    STDERR.puts('    Check to see that the document attachment can be deleted.')
    visit problem_report_problem_report_attachments_url(@problem_report)
    assert_selector "h1", text: "Problem Report Attachments"
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Problem Report attachment was successfully removed.'
    STDERR.puts('    The problem report attachment was deleted successfully.')
  end
end

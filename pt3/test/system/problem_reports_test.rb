require 'application_system_test_case'

class ProblemReportsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  setup do
    @project        = Project.find_by(identifier: 'TEST')
    @problem_report = ProblemReport.find_by(prid: 1)
    @file_data      = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                   'image/png',
                                                   true)

    user_tm
  end

  test 'should get problem reports list' do
    STDERR.puts('    Check to see that the Problem Reports List Page can be loaded.')
    visit project_filtered_problem_reports_url(@project)
    assert_selector 'h1', text: 'Select Problem Reports'
    click_on('Show Problem Reports')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    STDERR.puts('    The Problem Reports  List loaded successfully.')
  end

  test 'should create new problem report' do
    STDERR.puts('    Check to see that a new Problem Report can be created.')
    visit project_filtered_problem_reports_url(@project)
    assert_selector 'h1', text: 'Select Problem Reports'
    click_on('Show Problem Reports')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    click_on('New')
    assert_selector 'h1', text: 'New Problem Report'
    fill_in('Title', with: 'Test Problem Report to test Problem Reports with.')
    select('Hardware Item', from: 'problem_report_item_id')
    select('PHAC.doc', from: 'artifacts')
    click_on('Add')
    select('Source Code', from: 'artifact_type')
    select('alert_overpressure.c', from: 'artifacts')
    click_on('Add')
    select('Other', from: 'artifact_type')
    fill_in('other_artifacts_text', with: 'This is a test.')
    select('Team Member', from: 'problem_report_assignedto')
    fill_in('Product', with: 'PACT')
    select('Type 3B - Process (Insignificant Deviation)', from: 'problem_report_criticality')
    select('Other', from: 'problem_report_source')
    select('Manufacturing', from: 'problem_report_discipline_assigned')
    find('#problem_report_target_date').send_keys('01012050')
    page.all('div[contenteditable]')[0].send_keys('Test Problem Report to test Problem Reports with.')
    fill_in('problem_report_problemfoundin', with: 'Testing')
    fill_in('problem_report_meeting_id', with: 'Testing Meeting')
    click_on('Add File')
    attach_file("problem_report_attachment_file", Rails.root + "test/fixtures/files/alert_underpressure.c")
    click_on('Create Problem Report')
    assert_selector 'p', text: 'Problem report was successfully created.'
    assert_equal 4, ProblemReport.count
    STDERR.puts('    A new Report was successfully created.')
  end

  test 'should show problem report' do
    STDERR.puts('    Check to see that the Problem Report Show Page can be loaded.')
    visit project_filtered_problem_reports_url(@project)
    assert_selector 'h1', text: 'Select Problem Reports'
    click_on('Show Problem Reports')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Problem Report ID:'
    STDERR.puts('    The Problem Report Show Page loaded successfully.')
  end

  test 'should edit problem report' do
    STDERR.puts('    Check to see that a Problem Report can be edited.')

    STDERR.puts('    Check to see that a new Problem Report can be created.')
    visit project_filtered_problem_reports_url(@project)
    assert_selector 'h1', text: 'Select Problem Reports'
    click_on('Show Problem Reports')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    page.all('a', text: 'Edit')[1].click
    assert_selector 'h1', text: 'Editing Problem Report'
    fill_in('Title', with: 'Not Alerting on Over Pressure (Fixed).')
    select('Quality Assurance', from: 'problem_report_assignedto')
    select('Implemented', from: 'problem_report_status')
    fill_in('problem_report_fixed_in', with: 'Current Release')
    page.all('div[contenteditable]')[1].send_keys('[TM] - Added retry logic.')
    page.all('div[contenteditable]')[2].send_keys('Please Verify.')
    click_on('Update Problem Report')
    assert_selector 'p', text: 'Problem report was successfully updated.'

    problem_report = ProblemReport.find_by(title: 'Not Alerting on Over Pressure (Fixed).', project_id: @project.id)

    assert problem_report
    STDERR.puts('    A Problem Report was edited successfully.')
  end

  test 'should export problem reports' do
    STDERR.puts('    Check to see that the Problem Reports can be exported.')

    full_path = DOWNLOAD_PATH + '/Test-Problem_Reports.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit project_problem_reports_url(@project)
    assert_selector 'h1', text: 'Problem Reports List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Problem Reports'
    select('CSV', from: 'pr_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Problem_Reports.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit project_problem_reports_url(@project)
    assert_selector 'h1', text: 'Reports List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Problem Reports'
    select('XLS', from: 'pr_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Problem_Reports.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit project_problem_reports_url(@project)
    assert_selector 'h1', text: 'Reports List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Problem Reports'
    select('PDF', from: 'pr_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Problem_Reports.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit project_problem_reports_url(@project)
    assert_selector 'h1', text: 'Reports List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Problem Reports'
    select('DOCX', from: 'pr_export_export_type')
    click_on('Export')
    sleep(3)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)
    STDERR.puts('    The Problem Reports were successfully exported.')
  end

  test 'should import problem reports' do
    STDERR.puts('    Check to see that the Problem Reports can be imported.')

    visit project_problem_reports_url(@project)
    assert_selector 'h1', text: 'Problem Reports List'
    click_on('Import')
    select('Test', from: 'project_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Test-Problem_Reports.csv')
    check('_import_duplicates_permitted')
    click_on('Load Problem Reports')
    assert_selector 'p', text: 'Problem reports were successfully imported.'
    visit project_problem_reports_url(@project)
    assert_selector 'h1', text: 'Reports List'
    click_on('Import')
    select('Test', from: 'project_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Test-Problem_Reports.xls')
    check('_import_duplicates_permitted')
    click_on('Load Problem Reports')
    assert_selector 'p', text: 'Problem reports were successfully imported.'
    visit project_problem_reports_url(@project)
    assert_selector 'h1', text: 'Problem Reports List'
    click_on('Import')
    select('Test', from: 'project_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Test-Problem_Reports.xlsx')
    check('_import_duplicates_permitted')
    click_on('Load Problem Reports')
    assert_selector 'p', text: 'Problem reports were successfully imported.'
    STDERR.puts('    The Problem Reports were successfully imported.')
  end

  test 'should get all problem reports list' do
    STDERR.puts('    Check to see that the All Problem Reports List Page can be loaded.')
    visit project_filtered_problem_reports_url(@project)
    assert_selector 'h1', text: 'Select Problem Reports'
    click_on('Show Problem Reports')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    click_on('All Problem Reports')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    STDERR.puts('    The All Problem Reports  List loaded successfully.')
  end

  test 'should get all problem reports opened by me' do
    user_qa

    STDERR.puts('    Check to see that the Problem Reports Opened by Me Page can be loaded.')
    visit project_filtered_problem_reports_url(@project)
    assert_selector 'h1', text: 'Select Problem Reports'
    click_on('Show Problem Reports')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    click_on('PRs Opened by me')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    STDERR.puts('    The Problem Reports Opened by Me Page loaded successfully.')
  end

  test 'should get all problem reports assigned to me' do
    STDERR.puts('    Check to see that the Problem Reports Assigned to Me Page can be loaded.')
    visit project_filtered_problem_reports_url(@project)
    assert_selector 'h1', text: 'Select Problem Reports'
    click_on('Show Problem Reports')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    click_on('PRs Assigned to Me')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '1'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    STDERR.puts('    The Problem Reports Assigned to Me Page loaded successfully.')
  end

  test 'should get problem filtered reports list' do
    STDERR.puts('    Check to see that the Problem Reports List Page can be loaded.')
    visit project_filtered_problem_reports_url(@project)
    assert_selector 'h1', text: 'Select Problem Reports'
    select('Status', from: 'filter_field')
    fill_in('filter_value', with: 'Open')
    click_on('Show Problem Reports')
    assert_selector 'h1', text: 'Problem Reports List'
    assert_selector 'td', text: '2'
    assert_selector 'td', text: '3'
    STDERR.puts('    The Problem Reports  List loaded successfully.')
  end

end

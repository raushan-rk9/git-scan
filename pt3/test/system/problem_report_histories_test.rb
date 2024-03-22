require "application_system_test_case"

class ProblemReportHistoriesTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  setup do
    @project                = Project.find_by(identifier: 'TEST')
    @hardware_item          = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item          = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @problem_report         = ProblemReport.find_by(prid: 3)
    @problem_report_history = ProblemReportHistory.find_by(problem_report_id: @problem_report.id)

    user_pm
  end

  test "visiting the index" do
    STDERR.puts('    Check to see that the Problem Report History List Page can be loaded.')
    visit problem_report_problem_report_histories_url(@problem_report, @problem_report)
    assert_selector "h1", text: "Problem Report History List"
    STDERR.puts('    The Problem Report Historys  List loaded successfully.')
  end

  test 'should show problem report history' do
    STDERR.puts('    Check to see that the Problem Report History  view Page can be loaded.')
    visit problem_report_problem_report_histories_url(@problem_report, @problem_report)
    assert_selector "h1", text: "Problem Report History List"
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Problem Report History for:'
    STDERR.puts('    The Problem Report History view Page was successfully loaded.')
  end

  test "creating a Problem report history" do
    STDERR.puts('    Check to see that the problem report history view Page can be created.')
    visit new_problem_report_problem_report_history_url(@problem_report)
    assert_selector "h1", text: "New Problem Report History"
    fill_in('Action', with: 'Create Problem Report')
    fill_in('Status', with: 'Open')
    fill_in('Severity type', with: 'Type 3B - Process (Insignificant Deviation)')
    click_on "Create Problem report history"
    assert_text "Problem report history was successfully created."
    STDERR.puts('    The problem report history was created successfully.')
  end

  test "updating a Problem report history" do
    STDERR.puts('    Check to see that the problem report history view Page can be updated.')
    visit edit_problem_report_problem_report_history_url(@problem_report,
                                                         @problem_report_history)
    assert_selector "h1", text: "Editing Problem Report History"
    fill_in('Action', with: 'Create Problem Report')
    fill_in('Status', with: 'Open')
    fill_in('Severity type', with: 'Type 3B - Process (Insignificant Deviation)')
    click_on "Update Problem report history"
    assert_text "Problem report history was successfully updated."
    STDERR.puts('    The problem report history was updated successfully.')
  end
end

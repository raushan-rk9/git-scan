require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  setup do
    user_pm
  end

  test 'should get projects list' do
    STDERR.puts('    Check to see that the Projects List page can be loaded.')
    visit projects_url
    assert_selector 'h1', text: 'Projects List'
    assert_selector 'td', text: 'TEST'
    STDERR.puts('    The Projects List page loaded successfully.')
  end

  test 'should show Project' do
    STDERR.puts('    Check to see that a Project can be viewed.')
    visit projects_url
    assert_selector 'h1', text: 'Projects List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Name:'
    STDERR.puts('    The Project was viewed successfully.')
  end

  test "should create a Project" do
    STDERR.puts('    Check to see that a Project can be created.')
    visit projects_url
    assert_selector 'h1', text: 'Projects List'
    click_on('New Project')
    assert_selector 'h1', text: 'New Project'
    fill_in('Identifier', with: "TEST_PROJECT")
    fill_in('Name', with: "Test Project")
    fill_in('System requirements prefix', with: "SYSTEM")
    select("Project Manager", from: "Project Managers")
    select("Configuration Manager", from: "Configuration Managers")
    select("Quality Assurance", from: "Quality Assurance Members")
    select("Team Member", from: "Team Members")
    select("Certification Representative", from: "Certification Representatives")
    select("PROTECTED", from: "Access")
    select("Project Manager", from: "Permitted Users")
    select("Configuration Manager", from: "Permitted Users")
    select("Quality Assurance", from: "Permitted Users")
    select("Team Member", from: "Permitted Users")
    select("Certification Representative", from: "Permitted Users")
    click_on('Create Project')
    assert_selector 'p', text: 'Project was successfully created.'
    STDERR.puts('     A Project was successfully created.')
  end

  test 'should update Project' do
    STDERR.puts('    Check to see that a Project can be updated.')
    visit projects_url
    assert_selector 'h1', text: 'Projects List'
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Project'
    fill_in('Identifier', with: "TEST_PROJECT")
    fill_in('Name', with: "Test Project")
    fill_in('System requirements prefix', with: "SYSTEM")
    click_on('Update Project')
    assert_selector 'p', text: 'Project was successfully updated.'
    STDERR.puts('    The Project was updated successfully.')
  end

  test 'should delete a Project' do
    STDERR.puts('    Check to see a Project can be deleted.')
    visit projects_url
    assert_selector 'h1', text: 'Projects List'
    assert_selector 'a', text: "Delete"
    first('a', text: 'Delete').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Project was successfully removed.'
    STDERR.puts('    The Project was successfully deleted.')
  end
end

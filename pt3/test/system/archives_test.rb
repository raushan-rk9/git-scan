require "application_system_test_case"

class ArchivesTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  setup do
    @project            = Project.find_by(identifier: 'TEST')
    @hardware_item      = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item      = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user_pm
  end

  test 'should get archives list' do
    STDERR.puts('    Check to see that the Archives List page can be loaded.')
    visit project_archives_url(@project)
    assert_selector 'h1', text: 'Archives List'
    assert_selector 'td', text: 'TEST_001'
    STDERR.puts('    The Archives List page loaded successfully.')
  end

  test "should create an Archive" do
    clear_model_files
    STDERR.puts('    Check to see that an Archive can be created.')
    visit project_archives_url(@project)
    assert_selector 'h1', text: 'Archives List'
    click_on('New Archive')
    assert_selector 'h1', text: 'New Archive'
    fill_in('Name', with: 'TEST_002')
    fill_in('Archive ID', with: "Test Archive (002) - #{DateTime.now}")
    fill_in('Description', with: 'Test Project Archive (002)')
    click_on('Create Archive')
    assert_selector 'p', text: 'Archive was successfully created.'
    STDERR.puts('     An Archive was successfully created.')
  end

  test 'should show Archive' do
    STDERR.puts('    Check to see that an Archive can be viewed.')
    visit project_archives_url(@project)
    assert_selector 'h1', text: 'Archives List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Archive:'
    STDERR.puts('    The Archive was viewed successfully.')
  end

  test 'should update Archive' do
    STDERR.puts('    Check to see that an Archive can be updated.')
    visit project_archives_url(@project)
    assert_selector 'h1', text: 'Archives List'
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Archive'
    fill_in('Name', with: 'TEST 002')
    fill_in('Archive ID', with: "Updated Test Archive (002) - #{DateTime.now}")
    fill_in('Description', with: 'Updated Test Project Archive (002)')
    fill_in('Revision', with: 'a')
    click_on('Update Archive')
    assert_selector 'p', text: 'Archive was successfully updated.'
    STDERR.puts('    The Archive was updated successfully.')
  end

  test 'should delete an Archive' do
    STDERR.puts('    Check to see an Archive can be deleted.')
    visit project_archives_url(@project)
    assert_selector 'h1', text: 'Archives List'
    assert_selector 'a', exact_text: "delete\nDelete"
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Archive was successfully removed.'
    STDERR.puts('    The Archive was successfully deleted.')
  end

  test "should show Archives" do
    STDERR.puts('    Check to see that Archives can be shown.')
    visit project_archives_url(@project)
    assert_selector 'h1', text: 'Archives List'
    click_on('Show Archives')
    assert_selector 'h1', text: 'Archived Projects List'
    STDERR.puts('    The Archives can be shown.')
  end
end

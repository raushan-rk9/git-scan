require "application_system_test_case"

class TemplatesTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  def setup
    @template = Template.find_by(title: 'ACS DO-254 Templates')

    user_pm
  end

  test "should get template checklists list" do
    STDERR.puts('    Check to see that the Templates List Page can be loaded.')
    visit templates_url(awc: true)
    assert_selector "h1", text: "Templates List"
    STDERR.puts('    The Templates List Page loaded successfully.')
  end

  test 'should show template checklist' do
    STDERR.puts('    Check to see that the Template Show Page can be loaded.')
    visit templates_url(awc: true)
    assert_selector "h1", text: "Templates List"
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Template: '
    STDERR.puts('    The Template Show Page was loaded.')
  end

  test "should create a Template checklist" do
    STDERR.puts('    Check to see that a Template can be created.')
    visit templates_url(awc: true)
    assert_selector "h1", text: "Templates List"
    click_on "New Template" 
    assert_selector "h1", text: "New Template"
    fill_in('Template ID', with: '4')
    fill_in('Title', with: 'Test Template to test Templates Items with.')
    page.all('div[contenteditable]')[0].send_keys('Test Template to test Templates Items with.')
    page.all('div[contenteditable]')[1].send_keys('Manually Created.')
    fill_in('template_template_type', with: 'DO-178')
    fill_in('template_template_class', with: 'Transition Review')
    fill_in('Source', with: 'Airworthiness Certification Services')
    click_on "Create Template" 
    assert_text "Template was successfully created."
    STDERR.puts('    A Template was successfully created.')
  end

  test "should update a Template checklist" do
    STDERR.puts('    Check to see that the Template can be updated.')
    visit templates_url(awc: true)
    assert_selector "h1", text: "Templates List"
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector "h1", text: "Editing Template" 
    fill_in('Title', with: 'Test Template to test Templates Items with.')
    page.all('div[contenteditable]')[0].send_keys(' Updated.')
    page.all('div[contenteditable]')[1].send_keys(' Updated.')
    fill_in('template_template_type', with: 'DO-178')
    fill_in('template_template_class', with: 'Transition Review')
    fill_in('Source', with: 'Airworthiness Certification Services')
    click_on "Update Template" 
    STDERR.puts('    A Template was successfully updated.')
  end

  test "should delete a Template checklist" do
    STDERR.puts('    Check to see that the Template checklist can be deleted.')
    visit templates_url(awc: true)
    assert_selector "h1", text: "Templates List"
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Template was successfully removed.'
    STDERR.puts('    The action item Show Page was deleted.')
  end
end

require "application_system_test_case"

class TemplateChecklistsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  def setup
    @template           = Template.find_by(title: 'ACS DO-254 Templates')
    @template_checklist = TemplateChecklist.find_by(title: 'Plan for Hardware Aspects of Certification')

    user_pm
  end

  test "should get template checklists list" do
    STDERR.puts('    Check to see that the Template Checklists List Page can be loaded.')
    visit template_template_checklists_url(@template, awc: true)
    assert_selector "h1", text: "Template Checklists"
    STDERR.puts('    The Template Checklists List Page loaded successfully.')
  end

  test 'should show template checklist' do
    STDERR.puts('    Check to see that the Template Checklist Show Page can be loaded.')
    visit template_template_checklists_url(@template, awc: true)
    assert_selector "h1", text: "Template Checklists"
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Template Checklist:'
    STDERR.puts('    The Template Checklist Show Page was loaded.')
  end

  test "should create a Template checklist" do
    STDERR.puts('    Check to see that a Template Checklist can be created.')
    visit template_template_checklists_url(@template, awc: true)
    assert_selector "h1", text: "Template Checklists"
    click_on "New Template Checklist"
    assert_selector "h1", text: "New Template Checklist"
    fill_in('Title', with: 'Test Template Checklist to test Template Checklists Items with.')
    page.all('div[contenteditable]')[0].send_keys('Test Template Checklist to test Template Checklists Items with.')
    page.all('div[contenteditable]')[1].send_keys('Manually Created.')
    fill_in('template_checklist_checklist_class', with: 'DO-178')
    fill_in('template_checklist_checklist_type', with: 'Transition Review')
    fill_in('Source', with: 'Airworthiness Certification Services')
    fill_in('template_checklist_filename', with: 'test.xlsx')
    click_on "Create Template Checklist"
    assert_text "Template Checklist was successfully created."
    STDERR.puts('    A Template Checklist was successfully created.')
  end

  test "should update a Template checklist" do
    STDERR.puts('    Check to see that the Template Checklist can be updated.')
    visit template_template_checklists_url(@template, awc: true)
    assert_selector "h1", text: "Template Checklists"
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector "h1", text: "Editing Template Checklist"
    fill_in('Title', with: 'Test Template Checklist to test Template Checklists Items with.')
    page.all('div[contenteditable]')[0].send_keys('Test Template Checklist to test Template Checklists Items with.')
    page.all('div[contenteditable]')[1].send_keys('Manually Created.')
    fill_in('template_checklist_checklist_class', with: 'DO-178')
    fill_in('template_checklist_checklist_type', with: 'Transition Review')
    fill_in('Source', with: 'Airworthiness Certification Services')
    fill_in('template_checklist_filename', with: 'test.xlsx')
    click_on "Update Template Checklist"
    STDERR.puts('    A Template Checklist was successfully updated.')
  end

  test "should delete a Template checklist" do
    STDERR.puts('    Check to see that the Template checklist can be deleted.')
    visit template_template_checklists_url(@template, awc: true)
    assert_selector "h1", text: "Template Checklists"
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Template Checklist was successfully removed.'
    STDERR.puts('    The action item Show Page was deleted.')
  end
end

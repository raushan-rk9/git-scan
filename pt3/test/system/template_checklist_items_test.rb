require "application_system_test_case"

class TemplateChecklistItemsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  def setup
    @template                     = Template.find_by(title: 'ACS DO-254 Templates')
    @template_checklist           = TemplateChecklist.find_by(title: 'Plan for Hardware Aspects of Certification')
    @template_checklist_item_001  = TemplateChecklistItem.find_by(clitemid: 1)

    user_pm
  end

  test "should get template checklist items list" do
    STDERR.puts('    Check to see that the Template Checklist Items List Page can be loaded.')
    visit template_template_checklist_template_checklist_items_url(@template,
                                                                   @template_checklist)
    assert_selector "h1", text: "Template Checklist Items"
    STDERR.puts('    The Template Checklist Items List Page loaded successfully.')
  end

  test 'should show template checklist item' do
    STDERR.puts('    Check to see that the Template Checklist Item Show Page can be loaded.')
    visit template_template_checklist_template_checklist_items_url(@template,
                                                                   @template_checklist)
    assert_selector "h1", text: "Template Checklist Items"
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Template Checklist Item ID:'
    STDERR.puts('    The Template Checklist Item Show Page was loaded.')
  end

  test "should create a Template checklist item" do
    STDERR.puts('    Check to see that a Template Checklist Item can be created.')
    visit template_template_checklist_template_checklist_items_url(@template,
                                                                   @template_checklist)
    assert_selector "h1", text: "Template Checklist Items"
    click_on "New Template Checklist Item"
    assert_selector "h1", text: "New Template Checklist Item"
    page.all('div[contenteditable]')[0].send_keys('Test Template Checklist Item Item to test Template Checklists Items with.')
    fill_in('Reference', with: '10.1.1-1')
    select('A', from: 'template_checklist_item_minimumdal')
    select('Model Based', from: 'template_checklist_item_supplements')
    fill_in('Source', with: 'Airworthiness Certification Services')
    click_on "Create Template checklist item"
    assert_text "Template Checklist Item was successfully created."
    STDERR.puts('    A Template Checklist Item was successfully created.')
  end

  test "should update a Template checklist item" do
    STDERR.puts('    Check to see that a Template Checklist Item can be updated.')
    visit template_template_checklist_template_checklist_items_url(@template,
                                                                   @template_checklist)
    assert_selector "h1", text: "Template Checklist Items"
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector "h1", text: "Editing Template Checklist Item"
    page.all('div[contenteditable]')[0].send_keys(' Updated.')
    fill_in('Reference', with: '10.1.1-1')
    select('A', from: 'template_checklist_item_minimumdal')
    select('Model Based', from: 'template_checklist_item_supplements')
    fill_in('Source', with: 'Airworthiness Certification Services')
    click_on "Update Template checklist item"
    STDERR.puts('    A Template Checklist Item was successfully updated.')
  end

  test "should delete a Template checklist item" do
    STDERR.puts('    Check to see that the Template checklist item can be deleted.')
    visit template_template_checklist_template_checklist_items_url(@template,
                                                                   @template_checklist)
    assert_selector "h1", text: "Template Checklist Items"
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Template Checklist item was successfully removed.'
    STDERR.puts('    The Template Checklist Item was deleted.')
  end
end

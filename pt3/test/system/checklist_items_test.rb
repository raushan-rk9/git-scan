require "application_system_test_case"

class ChecklistItemsTest < ApplicationSystemTestCase
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
    @review         = Review.find_by(title: 'PHAC Review')
    @checklist_item = ChecklistItem.find_by(clitemid: 23)
    @hardware_item  = Item.find_by(identifier: 'HARDWARE_ITEM')

    user_pm
  end

  test 'should get a checklist items list' do
    STDERR.puts('    Check to see that the Checklist Item List Page can be loaded.')
    visit review_checklist_items_url(@review)
    assert_selector 'h1', text: 'Checklist Items List'

    for i in 1..23
      assert_selector 'td', text: i.to_s
    end

    STDERR.puts('    The Checklist Items  List loaded successfully.')
  end

  test 'should show a checklist item' do
    STDERR.puts('    Check to see that the Checklist Item Show Page can be loaded.')
    visit review_checklist_items_url(@review)
    assert_selector 'h1', text: 'Checklist Items List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Checklist Item ID:'
    STDERR.puts('    The Checklist Item Show Page was loaded.')
  end

  test 'should create a new checklist item' do
    STDERR.puts('    Check to see that a Checklist Item can be created.')
    visit item_reviews_url(@hardware_item)
    assert_selector "h1", text: "Reviews List"
    assert_selector "a", text: "Edit"
    click_on('Edit')
    assert_selector "h1", text: "Editing Review"
    click_on 'New Checklist Item'
    fill_in('checklist_item_clitemid', with: 24)
    page.all('div[contenteditable]')[0].send_keys('Test Checklist Item to test Checklist Items with.')
    fill_in('Reference', with: '10.2.1')
    fill_in('Applicable DAL', with: 'C')
    select('Model Based', from: 'checklist_item_supplements')
    select('N/A', from: 'Status')
    find('#checklist_item_evaluation_date').send_keys('01012050')
    select('PHAC.doc', from: 'Document')
    page.all('div[contenteditable]')[1].send_keys('Test Checklist Item to test Checklist Items with.')
    click_on 'Save Checklist Item'
    assert_selector 'p', text: 'Checklist item was successfully created.'
    STDERR.puts('    A Checklist Item was created.')
  end

  test 'should edit a checklist item' do
    STDERR.puts('    Check to see that a Checklist Item can be updated.')
    visit review_checklist_items_url(@review)
    assert_selector 'h1', text: 'Checklist Items List'
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    fill_in('checklist_item_clitemid', with: 24)
    page.all('div[contenteditable]')[0].send_keys('Test Checklist Item to test Checklist Items with.')
    fill_in('Reference', with: '10.2.1')
    fill_in('Applicable DAL', with: 'C')
    select('Model Based', from: 'checklist_item_supplements')
    select('N/A', from: 'Status')
    find('#checklist_item_evaluation_date').send_keys('01012050')
    select('PHAC.doc', from: 'Document')
    page.all('div[contenteditable]')[1].send_keys('Test Checklist Item to test Checklist Items with.')
    click_on 'Save Checklist Item'
    assert_selector 'p', text: 'Checklist item was successfully updated.'
    STDERR.puts('    A Checklist Item was updated.')
  end

  test 'should delete a checklist item' do
    STDERR.puts('    Check to see that a Checklist Item can be deleted.')
    visit review_checklist_items_url(@review)
    assert_selector 'h1', text: 'Checklist Items List'
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Checklist item was successfully removed.'
    STDERR.puts('    A Checklist Item was successfully deleted.')
  end
end

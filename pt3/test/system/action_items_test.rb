require "application_system_test_case"

class ActionItemsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  def setup
    @project         = Project.find_by(identifier: 'TEST')
    @hardware_item   = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item   = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_ai_001 = ActionItem.find_by(actionitemid: 1,
                                          item_id:      @hardware_item.id)
    @software_ai_001 = ActionItem.find_by(actionitemid: 1,
                                          item_id:      @software_item.id)
    @hardware_review = Review.find_by(reviewid: 1,
                                      item_id:      @hardware_item.id)
    @software_review = Review.find_by(reviewid: 2,
                                      item_id:      @software_item.id)

    user_pm
  end

  test 'should get action items list' do
    STDERR.puts('    Check to see that the Action Item List Page can be loaded.')
    visit review_action_items_url(@hardware_review)
    assert_selector 'h1', text: 'Action Items List'
    STDERR.puts('    The Action Items  List loaded successfully.')
  end

  test 'should show action item' do
    STDERR.puts('    Check to see that the action item Show Page can be loaded.')
    visit review_action_items_url(@hardware_review)
    assert_selector 'h1', text: 'Action Items List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Action Item ID:'
    STDERR.puts('    The action item Show Page was loaded.')
  end

  test 'should create new action item' do
    STDERR.puts('    Check to see that an Action Item can be created.')
    user_admin
    visit review_action_items_url(@hardware_review)
    assert_selector 'h1', text: 'Action Items List'
    click_on 'New Action Item'
    fill_in('action_item_actionitemid', with: 2)
    page.all('div[contenteditable]')[0].send_keys('Test Action Item to test Action Items with.')
    page.all('div[contenteditable]')[1].send_keys('Test Action Item to test Action Items with.')
    click_on 'Save Action Item'
    assert_selector 'p', text: 'Action item was successfully created.'
    STDERR.puts('    An Action Item was created.')
  end

  test 'should edit new action item' do
    STDERR.puts('    Check to see that an Action Item can be updated.')
    visit review_action_items_url(@hardware_review)
    assert_selector 'h1', text: 'Action Items List'
    assert_selector 'a', text: 'Edit'
    first('a', text: "Edit").click
    page.all('div[contenteditable]')[0].send_keys(' Updated.')
    page.all('div[contenteditable]')[1].send_keys(' Updated.')
    click_on 'Save Action Item'
    assert_selector 'p', text: 'Action item was successfully updated.'
    STDERR.puts('    An Action Item was updated.')
  end

  test 'should delete action item' do
    STDERR.puts('    Check to see that an action item can be deleted.')
    visit review_action_items_url(@hardware_review)
    assert_selector 'h1', text: 'Action Items List'
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Action item was successfully removed.'
    STDERR.puts('    An action item was successfully deleted.')
  end
end

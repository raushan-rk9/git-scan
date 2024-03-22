require "application_system_test_case"

class ItemsTest < ApplicationSystemTestCase
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
    @system_requirement = SystemRequirement.find_by(full_id: 'SYS-001')
    @model_file         = ModelFile.find_by(full_id: 'MF-001')
    @file_data          = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                       'image/png',
                                                       true)

    user_pm
  end

  test 'should get Items list' do
    STDERR.puts('    Check to see that the Items List Page can be loaded.')
    visit project_items_url(@project)
    assert_selector 'h1', text: 'Hardware/Software Items List'
    assert_selector 'td', text: 'HARDWARE_ITEM'
    assert_selector 'td', text: 'SOFTWARE_ITEM'
    STDERR.puts('    The Items List loaded successfully.')
  end

  test 'should create new item' do
    STDERR.puts('    Check to see that a new Item can be created.')
    visit project_items_url(@project)
    assert_selector 'h1', text: 'Hardware/Software Items List'
    click_on('New Item')
    assert_selector 'h1', text: 'New Hardware/Software Item'
    fill_in('Name', with: 'Test Item')
    select('DO-178 Airborne Software', from: 'item_itemtype')
    fill_in('Identifier', with: 'TEST_ITEM')
    select('C', from: 'item_level')
    fill_in('item_high_level_requirements_prefix', with: 'High_Level_Requirements')
    fill_in('item_low_level_requirements_prefix', with: 'Low_Level_Requirements')
    fill_in('item_model_file_prefix', with: 'Model_File')
    fill_in('item_source_code_prefix', with: 'Source_Code')
    fill_in('item_test_case_prefix', with: 'Test_Case')
    fill_in('item_test_procedure_prefix', with: 'Test_Procedure')
    click_on('Create Hardware/Software Item')
    assert_selector 'p', text: 'Item was successfully created.'
    assert_equal 3, SystemRequirement.count
    STDERR.puts('    A new item was successfully created.')
  end

  test 'should show item' do
    STDERR.puts('    Check to see that the Item Show Page can be loaded.')
    visit project_items_url(@project)
    assert_selector 'h1', text: 'Hardware/Software Items List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Hardware/Software Items:'
    STDERR.puts('    The Item Show Page loaded successfully.')
  end

  test 'should edit item' do
    STDERR.puts('    Check to see that an Item can be edited.')

    visit project_items_url(@project)
    assert_selector 'h1', text: 'Hardware/Software Items List'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Hardware/Software Item'
    fill_in('Name', with: 'Test Item')
    select('DO-178 Airborne Software', from: 'item_itemtype')
    fill_in('Identifier', with: 'TEST_ITEM')
    select('B', from: 'item_level')
    fill_in('item_high_level_requirements_prefix', with: 'High_Level_Requirements')
    fill_in('item_low_level_requirements_prefix', with: 'Low_Level_Requirements')
    fill_in('item_model_file_prefix', with: 'Model_File')
    fill_in('item_source_code_prefix', with: 'Source_Code')
    fill_in('item_test_case_prefix', with: 'Test_Case')
    fill_in('item_test_procedure_prefix', with: 'Test_Procedure')
    click_on('Update Hardware/Software Item')
    assert_selector 'p', text: 'Item was successfully updated.'
    STDERR.puts('    A new item was successfully edited.')
  end

  test 'should delete item' do
    STDERR.puts('    Check to see that a Item can be deleted.')
    visit project_items_url(@project)
    assert_selector 'h1', text: 'Hardware/Software Items List'
    assert_selector 'a', exact_text: "delete\nDelete"
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Item was successfully removed.'
    STDERR.puts('    The Item was successfully deleted.')
  end

  test 'should export items' do
    STDERR.puts('    Check to see that the System Requirements can be exported.')

    full_path = DOWNLOAD_PATH + '/Test-Items.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit project_items_url(@project)
    assert_selector 'h1', text: 'Hardware/Software Items List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Items'
    select('CSV', from: 'item_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Items.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit project_items_url(@project)
    assert_selector 'h1', text: 'Hardware/Software Items List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Items'
    select('XLS', from: 'item_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Items.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit project_items_url(@project)
    assert_selector 'h1', text: 'Hardware/Software Items List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Items'
    select('PDF', from: 'item_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Items.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit project_items_url(@project)
    assert_selector 'h1', text: 'Hardware/Software Items List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Items'
    select('DOCX', from: 'item_export_export_type')
    click_on('Export')
    sleep(3)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)
    STDERR.puts('    The Items were successfully exported.')
  end
end

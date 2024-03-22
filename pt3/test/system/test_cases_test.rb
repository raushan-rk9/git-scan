require 'application_system_test_case'

class TestCasesTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  setup do
    @hardware_item = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user_pm
  end

  test 'should get test cases list' do
    STDERR.puts('    Check to see that the Test Cases List Page can be loaded.')
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', text: 'TC-001'
    assert_selector 'a', text: 'TC-002'
    visit item_test_cases_url(@hardware_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', text: 'TC-001'
    assert_selector 'a', text: 'TC-002'
    STDERR.puts('    The Test Cases  List loaded successfully.')
  end

  test 'should create new test case' do
    STDERR.puts('    Check to see that a new Test Case can be created.')
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', text: 'TC-001'
    click_on('New Test Case')
    assert_selector 'h1', text: 'New Test Case'
    fill_in('test_case_description', with: 'To Test Test Cases.')
    find('div[contenteditable]').send_keys('Test Test Case to test Test Cases with.')
    check('test_case_robustness')
    select('Test', from: 'test_case_testmethod')
    select('Upload File', from: 'test_case_model_file_id')
    attach_file('test_case_upload_file', Rails.root + 'test/fixtures/files/flowchart.png')
    click_on('Link High-Level Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save High-Level Requirement Links')
    click_on('Link Low-Level Requirements')
    check('select_low_level_requirement_all_low_level_requirements')
    click_on('Save Low-Level Requirement Links')
    click_on('Save Test Case')
    assert_selector 'p', text: 'Test case was successfully created.'
    visit item_test_cases_url(@hardware_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', text: 'TC-001'
    click_on('New Test Case')
    assert_selector 'h1', text: 'New Test Case'
    fill_in('test_case_description', with: 'To Test Test Cases.')
    find('div[contenteditable]').send_keys('Test Test Case to test Test Cases with.')
    check('test_case_robustness')
    select('Test', from: 'test_case_testmethod')
    select('Upload File', from: 'test_case_model_file_id')
    attach_file('test_case_upload_file', Rails.root + 'test/fixtures/files/flowchart.png')
    click_on('Link Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save Requirement Links')
    click_on('Link Conceptual Design')
    check('select_low_level_requirement_all_low_level_requirements')
    click_on('Save Conceptual Design Links')
    click_on('Save Test Case')
    assert_selector 'p', text: 'Test case was successfully created.'
    STDERR.puts('    A new Requirement was successfully created.')
  end

  test 'should show test case' do
    STDERR.puts('    Check to see that the Test Case Show Page can be loaded.')
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Test Case ID:'
    visit item_test_cases_url(@hardware_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Test Case ID:'
    STDERR.puts('    The Test Case Show Page loaded successfully.')
  end

  test 'should edit test case' do
    STDERR.puts('    Check to see that a Test Case can be edited.')

    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Test Case'
    fill_in('test_case_full_id', with: 'TC-003')
    fill_in('test_case_description', with: 'To Test Updating Test Cases.')
    find('div[contenteditable]').send_keys(' Updated.')
    check('test_case_robustness')
    select('Analysis/Simulation', from: 'test_case_testmethod')
    click_on('Link High-Level Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save High-Level Requirement Links')
    click_on('Link Low-Level Requirements')
    check('select_low_level_requirement_all_low_level_requirements')
    click_on('Save Low-Level Requirement Links')
    click_on('Save Test Case')
    assert_selector 'p', text: 'Test Case was successfully updated.'

    test_case = TestCase.find_by(full_id: 'TC-003',
                                 item_id: @software_item.id)
    assert test_case
    visit item_test_cases_url(@hardware_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Test Case'
    fill_in('test_case_full_id', with: 'TC-004')
    fill_in('test_case_description', with: 'To Test Updating Test Cases.')
    find('div[contenteditable]').send_keys(' Updated.')
    check('test_case_robustness')
    select('Analysis/Simulation', from: 'test_case_testmethod')
    click_on('Link Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save Requirement Links')
    click_on('Save Test Case')
    assert_selector 'p', text: 'Test Case was successfully updated.'

    test_case = TestCase.find_by(full_id: 'TC-004',
                                 item_id: @hardware_item.id)

    assert test_case
    STDERR.puts('    A Test Case was edited successfully.')
  end

  test 'should delete test case' do
    STDERR.puts('    Check to see that the Test Case can be deleted.')
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', exact_text: "delete\nDelete"
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Test case was successfully removed.'
    STDERR.puts('    The Test Case was successfully deleted.')
  end

  test 'should mark test case as deleted' do
    STDERR.puts('    Check to see that the Test Case can be marked as deleted.')
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    assert_selector 'a', text: 'Mark As Deleted'
    first('a', text: 'Mark As Deleted').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Test case was successfully marked as deleted.'
    STDERR.puts('    The Test Case was successfully deleted.')
  end

  test 'should export test cases' do
    STDERR.puts('    Check to see that the Test Cases can be exported.')

    full_path = DOWNLOAD_PATH + '/Software Item-Test_Cases.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Test Cases'
    select('CSV', from: 'tc_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Hardware Item-Test_Cases.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit item_test_cases_url(@hardware_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Test Cases'
    select('XLS', from: 'tc_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-Test_Cases.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Test Cases'
    select('PDF', from: 'tc_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-Test_Cases.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Test Cases'
    select('DOCX', from: 'tc_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)
    STDERR.puts('    The Test Cases were successfully exported.')
  end

  test 'should import test cases' do
    STDERR.puts('    Check to see that the Test Cases can be imported.')
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('Import')
    select('Software Item', from: 'hlr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Test_Cases.csv')
    check('_import_duplicates_permitted')
    click_on('Load Test Cases')
    assert_selector 'p', text: 'Test Case requirements were successfully imported.'
    visit item_test_cases_url(@hardware_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('Import')
    select('Hardware Item', from: 'hlr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Test_Cases.xls')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Test Cases')
    assert_selector 'p', text: 'Test Case requirements were successfully imported.'
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('Import')
    select('Software Item', from: 'hlr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Test_Cases.xlsx')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Test Cases')
    assert_selector 'p', text: 'Test Case requirements were successfully imported.'
    STDERR.puts('    The Test Cases were successfully imported.')
  end

  test 'should renumber test cases' do
    STDERR.puts('    Check to see that the Test Case can be renumbered.')
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('Renumber')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Test Cases were successfully renumbered.'
    STDERR.puts('    The Test Cases were renumbered.')
  end

  test 'should create test cases baseline' do
    STDERR.puts('    Check to see that the Test Case can be baseline.')

# There is an issue in fixtures with attached model files for now unlink them.
# THis would not occur in real life as model files are attached at creation.

    sysreqs = SystemRequirement.all

    sysreqs.each do |sysreq|
      sysreq.model_file_id = nil

      sysreq.save!
    end

    hlrs = HighLevelRequirement.all

    hlrs.each do |hlr|
      hlr.model_file_id = nil

      hlr.save!
    end

    llrs = LowLevelRequirement.all

    llrs.each do |llr|
      llr.model_file_id = nil

      llr.save!
    end

    scs = SourceCode.all

    scs.each do |sc|
      sc.file_path = nil

      sc.save!
    end

    tcs = TestCase.all

    tcs.each do |tc|
      tc.model_file_id = nil

      tc.save!
    end

    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('New Baseline')
    click_on('Create Test Case Baseline')
    assert_selector 'p', text: 'Test Case baseline was successfully created.'
    STDERR.puts('    The Test Cases were baselined.')
  end

  test 'should view test cases baselines' do
    STDERR.puts('    Check to see that the Test Case Baselines List Page can be loaded.')
    visit item_test_cases_url(@software_item)
    assert_selector 'h1', text: 'Test Cases List'
    click_on('View Baselines')
    assert_selector 'h1', text: 'Test Case Baselines List'
    STDERR.puts('    The Test Case Baselines loaded successfully.')
  end
end

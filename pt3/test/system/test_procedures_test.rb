require 'application_system_test_case'

class TestProceduresTest < ApplicationSystemTestCase
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

  test 'should get test procedures list' do
    STDERR.puts('    Check to see that the Test Procedure List Page can be loaded.')
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', text: 'TP-001'
    assert_selector 'a', text: 'TP-002'
    visit item_test_procedures_url(@hardware_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', text: 'TP-001'
    assert_selector 'a', text: 'TP-002'
    STDERR.puts('    The Test Procedures  List loaded successfully.')
  end

  test 'should create new test procedure' do
    STDERR.puts('    Check to see that a new Test Procedure can be created.')
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', text: 'TP-001'
    click_on('New')
    assert_selector 'h1', text: 'New Test Procedure'
    find('div[contenteditable]').send_keys('Test Test Procedure to test Test Procedures with.')
    fill_in('test_procedure_file_name', with: 'overpressure.py')
    select('File Upload', from: 'test_procedure_url_type')
    attach_file("test_procedure_upload_file", Rails.root + "test/fixtures/files/overpressure.py")
    click_on('Link Test Case')
    check('select_test_case_all_test_cases')
    click_on('Save Test Case Links')
    click_on('Create Test Procedure')
    visit item_test_procedures_url(@hardware_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', text: 'TP-001'
    click_on('New')
    assert_selector 'h1', text: 'New Test Procedure'
    find('div[contenteditable]').send_keys('Test Test Procedure to test Test Procedures with.')
    fill_in('test_procedure_file_name', with: 'underpressure.py')
    select('File Upload', from: 'test_procedure_url_type')
    attach_file("test_procedure_upload_file", Rails.root + "test/fixtures/files/underpressure.py")
    click_on('Link Test Case')
    check('select_test_case_all_test_cases')
    click_on('Save Test Case Links')
    click_on('Create Test Procedure')
    assert_selector 'p', text: 'Test procedure was successfully created.'
    STDERR.puts('    A new Requirement was successfully created.')
  end

  test 'should show test procedure' do
    STDERR.puts('    Check to see that the Test Procedure Show Page can be loaded.')
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Test Procedure ID:'
    visit item_test_procedures_url(@hardware_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Test Procedure ID:'
    STDERR.puts('    The Test Procedure Show Page loaded successfully.')
  end

  test 'should edit test procedure' do
    STDERR.puts('    Check to see that a Test Procedure can be edited.')

    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Test Procedure'
    fill_in('test_procedure_full_id', with: 'TP-003')
    find('div[contenteditable]').send_keys(' Updated.')
    fill_in('test_procedure_file_name', with: 'underpressure.py')
    select('File Upload', from: 'test_procedure_url_type')
    attach_file("test_procedure_upload_file", Rails.root + "test/fixtures/files/underpressure.py")
    click_on('Link Test Case')
    check('select_test_case_all_test_cases')
    check('select_test_case_all_test_cases')
    click_on('Save Test Case Links')
    click_on('Update Test Procedure')
    assert_selector 'p', text: 'Test Procedure was successfully updated.'

    test_procedure = TestProcedure.find_by(full_id: 'TP-003',
                                 item_id: @software_item.id)

    assert test_procedure
    visit item_test_procedures_url(@hardware_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Test Procedure'
    fill_in('test_procedure_full_id', with: 'TP-004')
    find('div[contenteditable]').send_keys(' Updated.')
    fill_in('test_procedure_file_name', with: 'underpressure.py')
    select('File Upload', from: 'test_procedure_url_type')
    attach_file("test_procedure_upload_file", Rails.root + "test/fixtures/files/underpressure.py")
    click_on('Link Test Case')
    check('select_test_case_all_test_cases')
    check('select_test_case_all_test_cases')
    click_on('Save Test Case Links')
    click_on('Update Test Procedure')
    assert_selector 'p', text: 'Test Procedure was successfully updated.'

    test_procedure = TestProcedure.find_by(full_id: 'TP-004',
                                 item_id: @hardware_item.id)

    assert test_procedure
    STDERR.puts('    A Test Procedure was edited successfully.')
  end

  test 'should delete test procedure' do
    STDERR.puts('    Check to see that the Test Procedure can be deleted.')
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', exact_text: "delete\nDelete"
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Test procedure was successfully removed.'
    STDERR.puts('    The Test Procedure was successfully deleted.')
  end

  test 'should mark test procedure as deleted' do
    STDERR.puts('    Check to see that the Test Procedure can be marked as deleted.')
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    assert_selector 'a', text: 'Mark As Deleted'
    first('a', text: 'Mark As Deleted').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Test procedure was successfully marked as deleted.'
    STDERR.puts('    The Test Procedure was successfully deleted.')
  end

  test 'should export test procedures' do
    STDERR.puts('    Check to see that the Test Procedures can be exported.')

    full_path = DOWNLOAD_PATH + '/Software Item-Test_Procedures.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Test Procedures'
    select('CSV', from: 'tp_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Hardware Item-Test_Procedures.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit item_test_procedures_url(@hardware_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Test Procedures'
    select('XLS', from: 'tp_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-Test_Procedures.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Test Procedures'
    select('PDF', from: 'tp_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-Test_Procedures.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Test Procedures'
    select('DOCX', from: 'tp_export_export_type')
    click_on('Export')
    sleep(3)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)
    STDERR.puts('    The Test Procedures were successfully exported.')
  end

  test 'should import test procedures' do
    STDERR.puts('    Check to see that the Test Procedures can be imported.')
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('Import')
    select('Software Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Test_Procedures.csv')
    check('_import_duplicates_permitted')
    click_on('Load Test Procedures')
    assert_selector 'p', text: 'Test Procedure requirements were successfully imported.'
    visit item_test_procedures_url(@hardware_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('Import')
    select('Hardware Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Test_Procedures.xls')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Test Procedures')
    assert_selector 'p', text: 'Test Procedure requirements were successfully imported.'
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('Import')
    select('Software Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Test_Procedures.xlsx')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Test Procedures')
    assert_selector 'p', text: 'Test Procedure requirements were successfully imported.'
    STDERR.puts('    The Test Procedures were successfully imported.')
  end

  test 'should renumber test procedures' do
    STDERR.puts('    Check to see that the Test Procedure can be renumbered.')
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('Renumber')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Test Procedures were successfully renumbered.'
    STDERR.puts('    The Test Procedures were renumbered.')
  end

  test 'should create test procedures baseline' do
    STDERR.puts('    Check to see that the Test Procedure can be baseline.')

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

    FileUtils.cp('test/fixtures/files/underpressure.py',
                '/var/folders/test_procedures/test/underpressure.py')

   visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('New Baseline')
    click_on('Create Test Procedure Baseline')
    assert_selector 'p', text: 'Test Procedure baseline was successfully created.'
    STDERR.puts('    The Test Procedures were baselined.')
  end

  test 'should view test procedures baselines' do
    STDERR.puts('    Check to see that the Test Procedure Baselines List Page can be loaded.')
    visit item_test_procedures_url(@software_item)
    assert_selector 'h1', text: 'Test Procedure List'
    click_on('View Baselines')
    assert_selector 'h1', text: 'Test Procedure Baselines List'
    STDERR.puts('    The Test Procedure Baselines loaded successfully.')
  end
end

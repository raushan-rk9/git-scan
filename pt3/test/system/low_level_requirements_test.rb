require 'application_system_test_case'

class LowLevelRequirementsTest < ApplicationSystemTestCase
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

  test 'should get low level requirements list' do
    STDERR.puts('    Check to see that the Low-Level Requirements List Page can be loaded.')

    visit item_low_level_requirements_url(@software_item)

    assert_selector 'h1', text: 'Low-Level Requirements List'
    assert_selector 'a', text: 'LLR-001'
    assert_selector 'a', text: 'LLR-002'
    visit item_low_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Conceptual Design List'
    assert_selector 'a', text: 'LLR-001'
    assert_selector 'a', text: 'LLR-002'
    STDERR.puts('    The Low-Level Requirements  List loaded successfully.')
  end

  test 'should create new low level requirement' do
    STDERR.puts('    Check to see that a new Low-Level Requirement can be created.')
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    assert_selector 'a', text: 'LLR-001'
    click_on('New Low-Level Requirement')
    assert_selector 'h1', text: 'Low-Level Requirement'
    find('div[contenteditable]').send_keys('Test Low-Level Requirement to test Low-Level Requirements with.')
    fill_in('Category', with: 'Safety')
    select('Test', from: 'low_level_requirement_verification_method')
    select('Upload File', from: 'low_level_requirement_model_file_id')
    attach_file('low_level_requirement_upload_file', Rails.root + 'test/fixtures/files/flowchart.png')
    click_on('Link High-Level Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save High-Level Requirement Links')
    click_on('Save Low-Level Requirement')
    assert_selector 'p', text: 'Low level requirement was successfully created.'
    assert_equal 7, LowLevelRequirement.count
    visit item_low_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Conceptual Design List'
    assert_selector 'a', text: 'LLR-001'
    click_on('New Conceptual Design')
    assert_selector 'h1', text: 'Conceptual Design'
    find('div[contenteditable]').send_keys('Test Conceptual Design to test Conceptual Designs with.')
    fill_in('Category', with: 'Safety')
    select('Test', from: 'low_level_requirement_verification_method')
    select('Upload File', from: 'low_level_requirement_model_file_id')
    attach_file('low_level_requirement_upload_file', Rails.root + 'test/fixtures/files/flowchart.png')
    click_on('Link Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save Requirement Links')
    click_on('Save Conceptual Design')
    assert_selector 'p', text: 'Low level requirement was successfully created.'
    assert_equal 8, LowLevelRequirement.count
    STDERR.puts('    A new Requirement was successfully created.')
  end

  test 'should show low level requirement' do
    STDERR.puts('    Check to see that the Low-Level Requirement Show Page can be loaded.')
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Low-Level Requirements ID:'
    visit item_low_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Conceptual Design List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Conceptual Design ID:'
    STDERR.puts('    The Low-Level Requirement Show Page loaded successfully.')
  end

  test 'should edit low level requirement' do
    STDERR.puts('    Check to see that a Low-Level Requirement can be edited.')
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Low-Level Requirement'
    fill_in('low_level_requirement_full_id', with: 'LLR-003')
    find('div[contenteditable]').send_keys(' Updated.')
    fill_in('Category', with: 'Software')
    select('Analysis/Simulation', from: 'low_level_requirement_verification_method')
    click_on('Link High-Level Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save High-Level Requirement Links')
    click_on('Save Low-Level Requirement')
    assert_selector 'p', text: 'Low-Level Requirement was successfully updated.'

    low_level_requirement = LowLevelRequirement.find_by(full_id: 'LLR-003',
                                                          item_id: @software_item.id)
    assert low_level_requirement
    visit item_low_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Conceptual Design List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Conceptual Design'
    fill_in('low_level_requirement_full_id', with: 'LLR-004')
    find('div[contenteditable]').send_keys(' Updated.')
    fill_in('Category', with: 'Hardware')
    select('Analysis/Simulation', from: 'low_level_requirement_verification_method')
    click_on('Link Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save Requirement Links')
    click_on('Save Conceptual Design')
    assert_selector 'p', text: 'Conceptual Design was successfully updated.'

    low_level_requirement = LowLevelRequirement.find_by(full_id: 'LLR-004',
                                                          item_id: @hardware_item.id)

    assert low_level_requirement
    STDERR.puts('    A Low-Level Requirement was edited successfully.')
  end

  test 'should delete low level requirement' do
    STDERR.puts('    Check to see that the Low-Level Requirement can be deleted.')
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    assert_selector 'a', exact_text: "delete\nDelete"
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Low level requirement was successfully removed.'
    STDERR.puts('    The Low-Level Requirement was successfully deleted.')
  end

  test 'should mark low level requirement as deleted' do
    STDERR.puts('    Check to see that the Low-Level Requirement can be marked as deleted.')
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    assert_selector 'a', text: 'Mark As Deleted'
    first('a', text: 'Mark As Deleted').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Low level requirement was successfully marked as deleted.'
    STDERR.puts('    The Low-Level Requirement was successfully deleted.')
  end

  test 'should export low level requirements' do
    STDERR.puts('    Check to see that the Low-Level Requirements can be exported.')

    full_path = DOWNLOAD_PATH + '/Software Item-Low_Level_Requirements.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Low-Level Requirements'
    select('CSV', from: 'llr_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Hardware Item-Low_Level_Requirements.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit item_low_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Conceptual Design List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Conceptual Design'
    select('XLS', from: 'llr_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-Low_Level_Requirements.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Low-Level Requirements'
    select('PDF', from: 'llr_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-Low_Level_Requirements.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Low-Level Requirements'
    select('DOCX', from: 'llr_export_export_type')
    click_on('Export')
    sleep(3)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)
    STDERR.puts('    The Low-Level Requirements were successfully exported.')
  end

  test 'should import low level requirements' do
    STDERR.puts('    Check to see that the Low-Level Requirements can be imported.')

    visit item_low_level_requirements_url(@software_item)

    assert_selector 'h1', text: 'Low-Level Requirements List'
    click_on('Import')
    select('Software Item', from: 'hlr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Low_Level_Requirements.csv')
    check('_import_duplicates_permitted')
    click_on('Load Low-Level Requirements')
    assert_selector 'p', text: 'Low level requirements were successfully imported.'
    visit item_low_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Conceptual Design List'
    click_on('Import')
    select('Hardware Item', from: 'hlr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Low_Level_Requirements.xls')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Conceptual Design')
    assert_selector 'p', text: 'Low level requirements were successfully imported.'
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    click_on('Import')
    select('Software Item', from: 'hlr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Low_Level_Requirements.xlsx')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Low-Level Requirements')
    assert_selector 'p', text: 'Low level requirements were successfully imported.'

    STDERR.puts('    The Low-Level Requirements were successfully imported.')
  end

  test 'should renumber low level requirements' do
    STDERR.puts('    Check to see that the Low-Level Requirement can be renumbered.')
    visit item_low_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Low-Level Requirements List'
    click_on('Renumber')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Low level requirements were successfully renumbered.'
    STDERR.puts('    The Low-Level Requirements were renumbered.')
  end

  test 'should create low level requirements baseline' do
    STDERR.puts('    Check to see that the Low-Level Requirement can be baseline.')

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

    hlrs = LowLevelRequirement.all

    hlrs.each do |hlr|
      hlr.model_file_id = nil

      hlr.save!
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

    visit item_low_level_requirements_url(@software_item)

    assert_selector 'h1', text: 'Low-Level Requirements List'
    click_on('New Baseline')
    click_on('Create Low-Level Requirement Baseline')
    assert_selector 'p', text: 'Low Level Requirements baseline was successfully created.'
    STDERR.puts('    The Low-Level Requirements were baselined.')
  end

  test 'should view low level requirements baselines' do
    STDERR.puts('    Check to see that the Low-Level Requirement Baselines List Page can be loaded.')

    visit item_low_level_requirements_url(@software_item)

    assert_selector 'h1', text: 'Low-Level Requirements List'
    click_on('View Baselines')
    assert_selector 'h1', text: 'Low Level Requirements Baselines List'

    STDERR.puts('    The Low-Level Requirement Baselines loaded successfully.')
  end
end

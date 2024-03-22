require 'application_system_test_case'

class HighLevelRequirementsTest < ApplicationSystemTestCase
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

  test 'should get high level requirements list' do
    STDERR.puts('    Check to see that the High-Level Requirements List Page can be loaded.')

    visit item_high_level_requirements_url(@software_item)

    assert_selector 'h1', text: 'High-Level Requirements List'
    assert_selector 'a', text: 'HLR-001'
    assert_selector 'a', text: 'HLR-002'
    visit item_high_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Requirements List'
    assert_selector 'a', text: 'HLR-001'
    assert_selector 'a', text: 'HLR-002'
    STDERR.puts('    The High-Level Requirements  List loaded successfully.')
  end

  test 'should create new high level requirement' do
    STDERR.puts('    Check to see that a new High-Level Requirement can be created.')
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'High-Level Requirements List'
    assert_selector 'a', text: 'HLR-001'
    click_on('New High-Level Requirement')
    assert_selector 'h1', text: 'High-Level Requirement'
    find('div[contenteditable]').send_keys('Test High-Level Requirement to test High-Level Requirements with.')
    fill_in('Category', with: 'Safety')
    select('Test', from: 'high_level_requirement_verification_method')
    check('Safety Related')
    select('Upload File', from: 'high_level_requirement_model_file_id')
    attach_file('high_level_requirement_upload_file', Rails.root + 'test/fixtures/files/flowchart.png')
    click_on('Link System Requirements')
    check('select_system_requirement_all')
    click_on('Save System Requirement Links')
    click_on('Save High-Level Requirement')
    assert_selector 'p', text: 'High level requirement was successfully created.'
    assert_equal 7, HighLevelRequirement.count
    visit item_high_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Requirements List'
    assert_selector 'a', text: 'HLR-001'
    click_on('New Requirement')
    assert_selector 'h1', text: 'Requirement'
    find('div[contenteditable]').send_keys('Test Requirement to test Requirements with.')
    fill_in('Category', with: 'Safety')
    select('Test', from: 'high_level_requirement_verification_method')
    check('Safety Related')
    select('Upload File', from: 'high_level_requirement_model_file_id')
    attach_file('high_level_requirement_upload_file', Rails.root + 'test/fixtures/files/flowchart.png')
    click_on('Link System Requirements')
    check('select_system_requirement_all')
    click_on('Save System Requirement Links')
    click_on('Save Requirement')
    assert_selector 'p', text: 'High level requirement was successfully created.'
    assert_equal 8, HighLevelRequirement.count
    STDERR.puts('    A new Requirement was successfully created.')
  end

  test 'should show high level requirement' do
    STDERR.puts('    Check to see that the High-Level Requirement Show Page can be loaded.')
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'High-Level Requirements List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'High-Level Requirements ID:'
    visit item_high_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Requirements List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Requirements ID:'
    STDERR.puts('    The High-Level Requirement Show Page loaded successfully.')
  end

  test 'should edit high level requirement' do
    STDERR.puts('    Check to see that a High-Level Requirement can be edited.')
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'High-Level Requirements List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing High-Level Requirements'
    fill_in('high_level_requirement_full_id', with: 'HLR-003')
    find('div[contenteditable]').send_keys(' Updated.')
    fill_in('Category', with: 'Software')
    select('Analysis/Simulation', from: 'high_level_requirement_verification_method')
    check('Robustness')
    click_on('Link System Requirements')
    check('select_system_requirement_all')
    check('select_system_requirement_all')
    click_on('Save System Requirement Links')
    click_on('Link High-Level Requirements')
    select('HARDWARE_ITEM', from: 'high_level_item_select')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save High-Level Requirement Links')
    click_on('Save High-Level Requirement')
    assert_selector 'p', text: 'High-Level Requirement was successfully updated.'

    high_level_requirement = HighLevelRequirement.find_by(full_id: 'HLR-003',
                                                          item_id: @software_item.id)

    assert high_level_requirement
    visit item_high_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Requirements List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Requirements'
    fill_in('high_level_requirement_full_id', with: 'HLR-004')
    find('div[contenteditable]').send_keys(' Updated.')
    fill_in('Category', with: 'Hardware')
    select('Analysis/Simulation', from: 'high_level_requirement_verification_method')
    check('Robustness')
    click_on('Link System Requirements')
    check('select_system_requirement_all')
    check('select_system_requirement_all')
    click_on('Save System Requirement Links')
    click_on('Save Requirement')
    assert_selector 'p', text: 'Requirement was successfully updated.'

    high_level_requirement = HighLevelRequirement.find_by(full_id: 'HLR-004',
                                                          item_id: @hardware_item.id)

    assert high_level_requirement
    STDERR.puts('    A High-Level Requirement was edited successfully.')
  end

  test 'should delete high level requirement' do
    STDERR.puts('    Check to see that the High-Level Requirement can be deleted.')
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'High-Level Requirements List'
    assert_selector 'a', exact_text: "delete\nDelete"
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'High level requirement was successfully removed.'
    STDERR.puts('    The High-Level Requirement was successfully deleted.')
  end

  test 'should mark high level requirement as deleted' do
    STDERR.puts('    Check to see that the High-Level Requirement can be marked as deleted.')
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'High-Level Requirements List'
    assert_selector 'a', text: 'Mark As Deleted'
    first('a', text: 'Mark As Deleted').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'High level requirement was successfully marked as deleted.'
    STDERR.puts('    The High-Level Requirement was successfully deleted.')
  end

  test 'should export high level requirements' do
    STDERR.puts('    Check to see that the High-Level Requirements can be exported.')

    full_path = DOWNLOAD_PATH + '/Software Item-High_Level_Requirements.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'High-Level Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export High-Level Requirements'
    select('CSV', from: 'hlr_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Hardware Item-High_Level_Requirements.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit item_high_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Requirements'
    select('XLS', from: 'hlr_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-High_Level_Requirements.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export High-Level Requirements'
    select('PDF', from: 'hlr_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-High_Level_Requirements.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export High-Level Requirements'
    select('DOCX', from: 'hlr_export_export_type')
    click_on('Export')
    sleep(3)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    STDERR.puts('    The High-Level Requirements were successfully exported.')
  end

  test 'should import high level requirements' do
    STDERR.puts('    Check to see that the High-Level Requirements can be imported.')

    visit item_high_level_requirements_url(@software_item)

    assert_selector 'h1', text: 'High-Level Requirements List'
    click_on('Import')
    select('Software Item', from: 'hlr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-High_Level_Requirements.csv')
    check('_import_duplicates_permitted')
    click_on('Load High-Level Requirements')
    assert_selector 'p', text: 'High level requirements were successfully imported.'
    visit item_high_level_requirements_url(@hardware_item)
    assert_selector 'h1', text: 'Requirements List'
    click_on('Import')
    select('Hardware Item', from: 'hlr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-High_Level_Requirements.xls')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Requirements')
    assert_selector 'p', text: 'High level requirements were successfully imported.'
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'High-Level Requirements List'
    click_on('Import')
    select('Software Item', from: 'hlr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-High_Level_Requirements.xlsx')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load High-Level Requirements')
    assert_selector 'p', text: 'High level requirements were successfully imported.'

    STDERR.puts('    The High-Level Requirements were successfully imported.')
  end

  test 'should renumber high level requirements' do
    STDERR.puts('    Check to see that the High-Level Requirement can be renumbered.')
    visit item_high_level_requirements_url(@software_item)
    assert_selector 'h1', text: 'High-Level Requirements List'
    click_on('Renumber')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'High level requirements were successfully renumbered.'
    STDERR.puts('    The High-Level Requirements were renumbered.')
  end

  test 'should create high level requirements baseline' do
    STDERR.puts('    Check to see that the High-Level Requirement can be baseline.')

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

    visit item_high_level_requirements_url(@software_item)

    assert_selector 'h1', text: 'High-Level Requirements List'
    click_on('New Baseline')
    click_on('Create High-Level Requirement Baseline')
    assert_selector 'p', text: 'High Level Requirements baseline was successfully created.'
    STDERR.puts('    The High-Level Requirements were baselined.')
  end

  test 'should view high level requirements baselines' do
    STDERR.puts('    Check to see that the High-Level Requirement Baselines List Page can be loaded.')

    visit item_high_level_requirements_url(@software_item)

    assert_selector 'h1', text: 'High-Level Requirements List'
    click_on('View Baselines')
    assert_selector 'h1', text: 'High Level Requirements Baselines List'

    STDERR.puts('    The High-Level Requirement Baselines loaded successfully.')
  end
end

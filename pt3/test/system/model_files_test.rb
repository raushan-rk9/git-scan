require "application_system_test_case"

class ModelFilesTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  def unlink_model_file(id)
    system_requirements     = SystemRequirement.where(model_file_id: id)
    high_level_requirements = HighLevelRequirement.where(model_file_id: id)
    low_level_requirements  = LowLevelRequirement.where(model_file_id: id)
    test_cases              = TestCase.where(model_file_id: id)

    system_requirements.each     {|sysreq| sysreq.destroy} if system_requirements.present?
    high_level_requirements.each {|hlr|    hlr.destroy}    if high_level_requirements.present?
    low_level_requirements.each  {|llr|    llr.destroy}    if low_level_requirements.present?
    test_cases.each              {|tc|     tc.destroy}     if test_cases.present?
  end

  setup do
    @project                = Project.find_by(identifier: 'TEST')
    @hardware_item          = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item          = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @model_file_001         = ModelFile.find_by(full_id: 'MF-001')
    @model_file_002         = ModelFile.find_by(full_id: 'MF-002')
    @file_data              = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                           'image/png',
                                                           true)
    @model_file_001.item_id = nil

    @model_file_001.save!

    user_pm
  end

  test 'should get Model Files list' do
    STDERR.puts('    Check to see that the Model File List Page can be loaded.')
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    STDERR.puts('    The Model Files List loaded successfully.')
  end

  test 'should show model file' do
    STDERR.puts('    Check to see that the Model File Show Page can be loaded.')
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Model File ID:'
    visit item_model_files_url(@hardware_item)
    assert_selector 'h1', text: 'Model File List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Model File ID:'
    STDERR.puts('    The Model File Show Page loaded successfully.')
  end

  test 'should create new model file' do
    STDERR.puts('    Check to see that a new Model File can be created.')
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    click_on "New"
    fill_in "Model File ID", with: 'MF-003'
    page.all('div[contenteditable]')[0].send_keys('New Model File to Test Model FIles with.')
    select('File Upload', from: 'model_file_url_type')
    attach_file("model_file_upload_file", Rails.root + "test/fixtures/files/flowchart.png")
    click_on('Link System Requirements')
    check('select_system_requirement_all')
    click_on('Save System Requirement Links')
    find("#update_model_file").click
    assert_text "Model file was successfully created"
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    click_on "New"
    fill_in "Model File ID", with: 'MF-004'
    page.all('div[contenteditable]')[0].send_keys('New Model File to Test Model FIles with.')
    select('File Upload', from: 'model_file_url_type')
    attach_file("model_file_upload_file", Rails.root + "test/fixtures/files/flowchart.png")
    click_on('Link System Requirements')
    check('select_system_requirement_all')
    click_on('Save System Requirement Links')
    click_on('Link Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save Requirement Links')
    click_on('Link Conceptual Design')
    check('select_low_level_requirement_all_low_level_requirements')
    click_on('Save Conceptual Design Links')
    find("#update_model_file").click
    assert_text "Model file was successfully created"
    STDERR.puts('    A new Model File was successfully created.')
  end

  test "should edit a model file" do
    STDERR.puts('    Check to see that a new Model File can be updated.')
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Model File'
    fill_in "Model File ID", with: 'MF-003'
    page.all('div[contenteditable]')[0].send_keys('New Model File to Test Model FIles with.')
    select('File Upload', from: 'model_file_url_type')
    attach_file("model_file_upload_file", Rails.root + "test/fixtures/files/flowchart.png")
    click_on('Link System Requirements')
    check('select_system_requirement_all')
    click_on('Save System Requirement Links')
    find("#update_model_file").click
    assert_text "Model File was successfully updated."
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    assert_selector "h1", text: "Model File List"
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Model File'
    fill_in "Model File ID", with: 'MF-004'
    page.all('div[contenteditable]')[0].send_keys('New Model File to Test Model FIles with.')
    select('File Upload', from: 'model_file_url_type')
    attach_file("model_file_upload_file", Rails.root + "test/fixtures/files/flowchart.png")
    click_on('Link System Requirements')
    check('select_system_requirement_all')
    click_on('Save System Requirement Links')
    click_on('Link Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save Requirement Links')
    click_on('Link Conceptual Design')
    check('select_low_level_requirement_all_low_level_requirements')
    click_on('Save Conceptual Design Links')
    find("#update_model_file").click
    assert_text "Model File was successfully updated."
    STDERR.puts('    A new Model File was successfully updated.')
  end

  test 'should delete model file' do
    STDERR.puts('    Check to see that the Model File can be deleted.')
    unlink_model_file(@model_file_001.id)
    unlink_model_file(@model_file_002.id)
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    assert_selector 'a', text: 'Edit'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Model File was successfully removed.'
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    assert_selector 'a', text: 'Edit'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Model File was successfully removed.'
    STDERR.puts('    The Model File was successfully deleted.')
  end

  test 'should mark model file as deleted' do
    STDERR.puts('    Check to see that the Model File can be marked as deleted.')
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    assert_selector 'a', text: 'Mark As Deleted'
    first('a', text: 'Mark As Deleted').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Model file was successfully marked as deleted.'
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    assert_selector 'a', text: 'Mark As Deleted'
    first('a', text: 'Mark As Deleted').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Model file was successfully marked as deleted.'
    STDERR.puts('    The Model File was successfully deleted.')
  end

  test 'should export model files' do
    STDERR.puts('    Check to see that the Model Files can be exported.')

    full_path = DOWNLOAD_PATH + '/Test-Model_Files.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Model File'
    select('CSV', from: 'mf_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Model_Files.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector "h1", text: "Export Model File"
    select('XLS', from: 'mf_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Model_Files.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Model File'
    select('PDF', from: 'mf_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Model_Files.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Model File'
    select('DOCX', from: 'mf_export_export_type')
    click_on('Export')
    sleep(3)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Hardware Item-Model_Files.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Model File'
    select('CSV', from: 'mf_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Hardware Item-Model_Files.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector "h1", text: "Export Model File"
    select('XLS', from: 'mf_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Hardware Item-Model_Files.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Model File'
    select('PDF', from: 'mf_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Hardware Item-Model_files.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Model File'
    select('DOCX', from: 'mf_export_export_type')
    click_on('Export')
    sleep(3)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)
    STDERR.puts('    The Model Files were successfully exported.')
  end

  test 'should import model files' do
    STDERR.puts('    Check to see that the Model Files can be imported.')
    visit project_model_files_url(@project)
    assert_selector "h1", text: "Model File List"
    click_on('Import')
    select('Hardware Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Test-Model_Files.csv')
    check('_import_duplicates_permitted')
    click_on('Load Model Files')
    assert_selector 'p', text: 'Model Files successfully imported.'
    visit project_model_files_url(@project)
    assert_selector 'h1', text: 'Model File List'
    click_on('Import')
    select('Hardware Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Test-Model_Files.xls')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Model Files')
    assert_selector 'p', text: 'Model Files successfully imported.'
    visit project_model_files_url(@project)
    assert_selector 'h1', text: 'Model File List'
    click_on('Import')
    select('Hardware Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Test-Model_Files.xlsx')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Model Files')
    assert_selector 'p', text: 'Model Files successfully imported.'
    visit item_model_files_url(@hardware_item)
    assert_selector "h1", text: "Model File List"
    click_on('Import')
    select('Hardware Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Model_Files.csv')
    check('_import_duplicates_permitted')
    click_on('Load Model Files')
    assert_selector 'p', text: 'Model Files successfully imported.'
    visit item_model_files_url(@hardware_item)
    assert_selector 'h1', text: 'Model File List'
    click_on('Import')
    select('Hardware Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Model_Files.xls')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Model Files')
    assert_selector 'p', text: 'Model Files successfully imported.'
    visit item_model_files_url(@software_item)
    assert_selector 'h1', text: 'Model File List'
    click_on('Import')
    select('Hardware Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Model_Files.xlsx')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Model Files')
    assert_selector 'p', text: 'Model Files successfully imported.'
    STDERR.puts('    The Model Files were successfully imported.')
  end

  test 'should renumber model files' do
    STDERR.puts('    Check to see that the Model File can be renumbered.')
    visit project_model_files_url(@project)
    assert_selector 'h1', text: 'Model File List'
    click_on('Renumber')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'model files were successfully renumbered.'
    visit item_model_files_url(@hardware_item)
    assert_selector 'h1', text: 'Model File List'
    click_on('Renumber')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'model files were successfully renumbered.'
    STDERR.puts('    The Model Files were renumbered.')
  end
end

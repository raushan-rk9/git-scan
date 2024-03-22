require 'application_system_test_case'

class SystemRequirementsTest < ApplicationSystemTestCase
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

  test 'should get system requirements list' do
    STDERR.puts('    Check to see that the System Requirements List Page can be loaded.')
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    assert_selector 'a', text: 'SYS-001'
    assert_selector 'a', text: 'SYS-002'
    STDERR.puts('    The System Requirements  List loaded successfully.')
  end

  test 'should create new system requirement' do
    STDERR.puts('    Check to see that a new System Requirement can be created.')
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    assert_selector 'a', text: 'SYS-001'
    click_on('New')
    assert_selector 'h1', text: 'New System Requirement'
    find('div[contenteditable]').send_keys('Test System Requirement to test System Requirements with.')
    fill_in('Category', with: 'Safety')
    select('Test', from: 'system_requirement_verification_method')
    fill_in('Source', with: 'Client')
    check('Safety Related')
    fill_in('Implementation', with: 'Software')
    select('Upload File', from: 'system_requirement_model_file_id')
    attach_file('system_requirement_upload_file', Rails.root + 'test/fixtures/files/flowchart.png')
    click_on('Save System Requirement')
    assert_selector 'p', text: 'System requirement was successfully created.'
    assert_equal 4, SystemRequirement.count
    STDERR.puts('    A new Requirement was successfully created.')
  end

  test 'should show system requirement' do
    STDERR.puts('    Check to see that the System Requirement Show Page can be loaded.')
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'System Requirement ID:'
    STDERR.puts('    The System Requirement Show Page loaded successfully.')
  end

  test 'should edit system requirement' do
    STDERR.puts('    Check to see that a System Requirement can be edited.')

    @system_requirement.model_file_id = nil

    @system_requirement.save!

    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing System Requirement'
    fill_in('system_requirement_full_id', with: 'SYS-003')
    find('div[contenteditable]').send_keys(' Updated.')
    fill_in('Category', with: 'Robustness')
    select('Analysis/Simulation', from: 'system_requirement_verification_method')
    fill_in('Source', with: 'Client Requirement')
    check('Safety Related')
    fill_in('Implementation', with: 'Hardware')
    select('Upload/Replace File', from: 'system_requirement_model_file_id')
    attach_file('system_requirement_upload_file', Rails.root + 'test/fixtures/files/flowchart.png')
    click_on('Save System Requirement')
    assert_selector 'p', text: 'System requirement was successfully updated.'

    system_requirement = SystemRequirement.find_by(full_id: 'SYS-003',
                                                          project_id: @project.id)

    assert system_requirement
    STDERR.puts('    A System Requirement was edited successfully.')
  end

  test 'should delete system requirement' do
    STDERR.puts('    Check to see that the System Requirement can be deleted.')
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    assert_selector 'a', exact_text: "delete\nDelete"
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'System requirement was successfully removed.'
    STDERR.puts('    The System Requirement was successfully deleted.')
  end

  test 'should mark system requirement as deleted' do
    STDERR.puts('    Check to see that the System Requirement can be marked as deleted.')
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    assert_selector 'a', text: 'Mark As Deleted'
    first('a', text: 'Mark As Deleted').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'System requirement was successfully marked as deleted.'
    STDERR.puts('    The System Requirement was successfully deleted.')
  end

  test 'should export system requirements' do
    STDERR.puts('    Check to see that the System Requirements can be exported.')

    full_path = DOWNLOAD_PATH + '/Test-System_Requirements.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export System Requirements'
    select('CSV', from: 'sysreq_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-System_Requirements.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export System Requirements'
    select('XLS', from: 'sysreq_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-System_Requirements.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export System Requirements'
    select('PDF', from: 'sysreq_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-System_Requirements.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'Requirements List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export System Requirements'
    select('DOCX', from: 'sysreq_export_export_type')
    click_on('Export')
    sleep(3)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)
    STDERR.puts('    The System Requirements were successfully exported.')
  end

  test 'should import system requirements' do
    STDERR.puts('    Check to see that the System Requirements can be imported.')

    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    click_on('Import')
    select('Test', from: 'project_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Test-System_Requirements.csv')
    check('_import_duplicates_permitted')
    click_on('Load System Requirements')
    assert_selector 'p', text: 'System requirements were successfully imported.'
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'Requirements List'
    click_on('Import')
    select('Test', from: 'project_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Test-System_Requirements.xls')
    check('_import_duplicates_permitted')
    click_on('Load System Requirements')
    assert_selector 'p', text: 'System requirements were successfully imported.'
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    click_on('Import')
    select('Test', from: 'project_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Test-System_Requirements.xlsx')
    check('_import_duplicates_permitted')
    click_on('Load System Requirements')
    assert_selector 'p', text: 'System requirements were successfully imported.'
    STDERR.puts('    The System Requirements were successfully imported.')
  end

  test 'should renumber system requirements' do
    STDERR.puts('    Check to see that the System Requirement can be renumbered.')
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    click_on('Renumber')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'System requirements were successfully renumbered.'
    STDERR.puts('    The System Requirements were renumbered.')
  end

  test 'should create system requirements baseline' do
    STDERR.puts('    Check to see that the System Requirement can be baseline.')

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

    visit project_system_requirements_url(@project)

    assert_selector 'h1', text: 'System Requirements List'
    click_on('New Baseline')
    click_on('Create System Requirement Baseline')
    assert_selector 'p', text: 'System Requirements baseline was successfully created.'
    STDERR.puts('    The System Requirements were baselined.')
  end

  test 'should view system requirements baselines' do
    STDERR.puts('    Check to see that the System Requirement Baselines List Page can be loaded.')
    visit project_system_requirements_url(@project)
    assert_selector 'h1', text: 'System Requirements List'
    click_on('View Baselines')
    assert_selector 'h1', text: 'System Requirements Baselines List'
    STDERR.puts('    The System Requirement Baselines loaded successfully.')
  end

  test 'should view system requirements allocation' do
    STDERR.puts('    Check to see that the System Requirement Allocation can be viewed.')
    visit project_system_requirements_allocation_url(@project)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Requirements Tracing'
    assert_selector 'p', text: 'The System SHALL maintain proper pump pressure.'
    STDERR.puts('    The System Requirement Allocation was viewed successfully.')
  end

  test 'should view Not Outlinked System Requirements' do
    STDERR.puts('    Check to see that the Not Outlinked System Requirements can be viewed.')
    visit project_system_requirements_unallocated_url(@project)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Requirements Tracing'
    assert_selector 'h5', text: 'Not Outlinked System Requirements'
    assert_selector 'p', text: 'The System SHALL provide an external interface to monitor pump pressure.'
    STDERR.puts('    The Not Outlinked System Requirements were viewed successfully.')
  end
end

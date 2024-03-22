require 'application_system_test_case'

class RequirementsTracingTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  setup do
    @project       = Project.find_by(identifier: 'TEST')
    @hardware_item = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user_pm
  end

  test "should get index" do
    STDERR.puts "should get index"
    visit item_requirements_tracing_url(@software_item)
    assert_selector 'h1', text: 'Requirements Tracing'
    find('#system_requirements').click
    find('#high_level_requirements').click
    find('#source_code').click
    find('#test_cases').click
    find('#low_level_requirements').click
    find('#reverse').click
    assert(!find('#system_requirements').checked?)
    assert(!find('#high_level_requirements').checked?)
    assert(!find('#low_level_requirements').checked?)
    assert(!find('#source_code').checked?)
    assert(!find('#test_cases').checked?)
    assert(!find('#test_procedures').checked?)
    find('#system_requirements').click
    find('#low_level_requirements').click
    assert(find('#high_level_requirements').checked?)
    find('#test_cases').click
    find('#source_code').click
    find('#test_procedures').click
    find('#forward').click
    assert(find('#system_requirements').checked?)
    assert(find('#high_level_requirements').checked?)
    assert(find('#low_level_requirements').checked?)
    assert(find('#source_code').checked?)
    assert(find('#test_cases').checked?)
    assert(find('#test_procedures').checked?)
    STDERR.puts "should get index succeded."
  end

  test "should view requirements tracing matrix" do
    STDERR.puts "should view requirements tracing matrix"
    visit item_requirements_tracing_url(@software_item)
    assert_selector 'h1', text: 'Requirements Tracing'
    find('#system_requirements').click
    find('#high_level_requirements').click
    find('#source_code').click
    find('#test_cases').click
    find('#low_level_requirements').click
    find('#reverse').click
    assert(!find('#system_requirements').checked?)
    assert(!find('#high_level_requirements').checked?)
    assert(!find('#low_level_requirements').checked?)
    assert(!find('#source_code').checked?)
    assert(!find('#test_cases').checked?)
    assert(!find('#test_procedures').checked?)
    find('#system_requirements').click
    find('#low_level_requirements').click
    assert(find('#high_level_requirements').checked?)
    find('#test_cases').click
    find('#source_code').click
    find('#test_procedures').click
    find('#forward').click
    assert(find('#system_requirements').checked?)
    assert(find('#high_level_requirements').checked?)
    assert(find('#low_level_requirements').checked?)
    assert(find('#source_code').checked?)
    assert(find('#test_cases').checked?)
    assert(find('#test_procedures').checked?)
    click_on 'View'

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h5', text: 'System Requirements to SOFTWARE_ITEM High-Level Requirements to HARDWARE_ITEM High-Level Requirements to Low-Level Requirements to Source Code to Test Cases to Test Procedures'
    assert_selector 'th', text: 'System Requirements'
    assert_selector 'th', text: 'SOFTWARE_ITEM High-Level Requirements'
    assert_selector 'th', text: 'HARDWARE_ITEM High-Level Requirements'
    assert_selector 'th', text: 'Low-Level Requirements'
    assert_selector 'th', text: 'Source Code'
    assert_selector 'th', text: 'Test Cases'
    assert_selector 'th', text: 'Test Procedures'
    assert_selector 'p',  text: 'The System SHALL maintain proper pump pressure.'
    assert_selector 'p',  text: 'The System SHALL monitor the check value to prevent under-pressure.'
    assert_selector 'p',  text: 'The System SHALL monitor the check value to prevent over-pressure.'

    trs = page.all('tr')

    assert(6, trs.length)
    STDERR.puts "Viewing requirements tracing matrix succeded"
  end

  test "should get unlinked" do
    STDERR.puts "should get unlinked"
    STDERR.puts "should view requirements tracing matrix"
    visit item_requirements_tracing_url(@software_item)
    assert_selector 'h1', text: 'Requirements Tracing'
    click_on 'Not Inlinked'

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Requirements Tracing'
    assert_selector 'h5', text: 'Not Inlinked High-Level Requirements'
    assert_selector 'h5', text: 'Not Inlinked Low-Level Requirements'
    assert_selector 'p',  text: 'The System SHALL have a test mode to verify functionality.'
    assert_selector 'p',  text: 'The System SHALL have a test mode to verify functionality.'
    STDERR.puts "should get unlinked succeded."
  end

  test "should get not outlinked" do
    STDERR.puts "should get not outlinked"
    STDERR.puts "should view requirements tracing matrix"
    visit item_requirements_tracing_url(@software_item)
    assert_selector 'h1', text: 'Requirements Tracing'
    click_on 'Not Outlinked'

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Requirements Tracing'
    STDERR.puts "should get not outlinked succeded."
  end

  test "should get derived" do
    STDERR.puts "should get derived"
    visit item_requirements_tracing_url(@software_item)
    assert_selector 'h1', text: 'Requirements Tracing'
    click_on 'Derived'

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Requirements Tracing'
    assert_selector 'h5', text: 'Derived High-Level Requirements'
    assert_selector 'h5', text: 'Derived Low-Level Requirements'
    assert_selector 'h5', text: 'Derived Test Cases'
    assert_selector 'p',  text: 'The System SHALL have a test mode to verify functionality.'
    STDERR.puts "should get derived succeded."
  end

  test "should export requirements tracing matrix" do
    STDERR.puts('    Check to see that the Requirements Tracing Matrix can be exported.')

    full_path = DOWNLOAD_PATH + '/Test-Software Item-Requirements Tracing Matrix.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit item_requirements_tracing_url(@software_item)
    assert_selector 'h1', text: 'Requirements Tracing'
    click_on 'Export'

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Requirements Tracing Matrix'
    select('CSV', from: 'rtm_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Software Item-Requirements Tracing Matrix.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit item_requirements_tracing_url(@software_item)
    assert_selector 'h1', text: 'Requirements Tracing'
    click_on 'Export'

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Requirements Tracing Matrix'
    select('XLS', from: 'rtm_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Software Item-Requirements Tracing Matrix.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit item_requirements_tracing_url(@software_item)
    assert_selector 'h1', text: 'Requirements Tracing'
    click_on 'Export'

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Requirements Tracing Matrix'
    select('PDF', from: 'rtm_export_export_type')
    click_on('Export')
    sleep(10)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Test-Software Item-Requirements Tracing Matrix.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit item_requirements_tracing_url(@software_item)
    assert_selector 'h1', text: 'Requirements Tracing'
    click_on 'Export'

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Requirements Tracing Matrix'
    select('DOCX', from: 'rtm_export_export_type')
    click_on('Export')
    sleep(3)
    File.delete(full_path) if File.exist?(full_path)
    STDERR.puts "The Requirements Tracing Matrix was exported successfully."
  end
end

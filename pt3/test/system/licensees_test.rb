require "application_system_test_case"

class LicenseesTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  def setup
    @licensee = Licensee.find_by(identifier: 'test')

    user_admin
  end

  test "visiting the index" do
    STDERR.puts('    Check to see that the Licensee List Page can be loaded.')
    visit licensees_url
    assert_selector "h1", text: "Organizations"
    STDERR.puts('    The Licensee List Page loaded successfully.')
  end

  test "creating a Licensee" do
    STDERR.puts('    Check to see that a new Licensee can created.')
    visit licensees_url
    assert_selector "h1", text: "Organizations"
    click_on "New Organization"
    fill_in "Identifier", with: @licensee.identifier + '2'
    fill_in "Name", with: @licensee.name
    page.all('div[contenteditable]')[0].send_keys('Licensee to test Licensess with.')
    fill_in "Setup date", with: @licensee.setup_date
    fill_in "License date", with: @licensee.license_date
    fill_in "Renewal date", with: @licensee.renewal_date
    fill_in "License type", with: @licensee.license_type
    fill_in "licensee_contact_emails", with: 'admin@faaconsultants.com'
    page.all('div[contenteditable]')[0].send_keys(@licensee.contact_information)
    click_on "Create Organization"
    assert_text "Licensee was successfully created"
    STDERR.puts('    A new Licensee was created.')
  end

  test "updating a Licensee" do
    STDERR.puts('    Check to see that a new Licensee can updated.')
    visit licensees_url
    click_on "Edit", match: :first
    fill_in "Identifier", with: @licensee.identifier + '2'
    fill_in "Name", with: @licensee.name
    page.all('div[contenteditable]')[0].send_keys(' Updated.')
    fill_in "Setup date", with: @licensee.setup_date
    fill_in "License date", with: @licensee.license_date
    fill_in "Renewal date", with: @licensee.renewal_date
    fill_in "License type", with: @licensee.license_type
    fill_in "licensee_contact_emails", with: 'admin@faaconsultants.com'
    page.all('div[contenteditable]')[0].send_keys(@licensee.contact_information)
    click_on "Update Organization"
    assert_text "Licensee was successfully updated"
    STDERR.puts('    A new Licensee was updated.')
  end

  test "destroying a Licensee" do
    STDERR.puts('    Check to see that a Licensee can deleted.')
    visit licensees_url
    assert_selector "h1", text: "Organizations"
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_text "Licensee was successfully removed."
    STDERR.puts('    A Licensee was deleted.')
  end
end

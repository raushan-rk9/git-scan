require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  setup do
    user_admin
  end

  test 'should get users list' do
    STDERR.puts('    Check to see that the Users List page can be loaded.')
    visit users_url
    assert_selector 'h1', text: 'Users List'
    assert_selector 'td', text: 'test_1@airworthinesscert.com'
    STDERR.puts('    The Users List page loaded successfully.')
  end

  test 'should show User' do
    STDERR.puts('    Check to see that a User can be viewed.')
    visit users_url
    assert_selector 'h1', text: 'Users List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h6', text: 'Details:'
    STDERR.puts('    The User was viewed successfully.')
  end

  test "should create a User" do
    STDERR.puts('    Check to see that a User can be created.')
    visit users_url
    assert_selector 'h1', text: 'Users List'
    click_on('New User')
    assert_selector 'h1', text: 'New User'
    fill_in('Email', with: 'paulc@patmos-eng.com')
    fill_in('First Name', with: 'Paul')
    fill_in('Last Name', with: 'Carrick')
    fill_in('Title', with: 'Senior Software Engineer')
    fill_in('Phone', with: '(800) 555-1212')
    fill_in('Password', with: 'Ruddygor38!')
    select("Project Manager", from: "Role")
    click_on('Create User')
    assert_selector 'p', text: 'User was successfully created.'
    click_on('Log Out')
    fill_in('Email', with: 'paulc@patmos-eng.com')
    fill_in('Password', with: 'Ruddygor38!')
    click_on('Log in')
    assert_selector 'p', text: 'Signed in successfully.'
    STDERR.puts('     A User was successfully created.')
  end

  test "should Create a User with Password Reset" do
    STDERR.puts('    Check to see that a User can be created.')
    visit users_url
    assert_selector 'h1', text: 'Users List'
    click_on('New User')
    assert_selector 'h1', text: 'New User'
    fill_in('Email', with: 'paulc@patmos-eng.com')
    fill_in('First Name', with: 'Paul')
    fill_in('Last Name', with: 'Carrick')
    fill_in('Title', with: 'Senior Software Engineer')
    fill_in('Phone', with: '(800) 555-1212')
    fill_in('Password', with: 'Ruddygor38!')
    select("Project Manager", from: "Role")
    check('user_password_reset_required')
    click_on('Create User')
    assert_selector 'p', text: 'User was successfully created.'
    click_on('Log Out')
    fill_in('Email', with: 'paulc@patmos-eng.com')
    fill_in('Password', with: 'Ruddygor38!')
    click_on('Log in')
    assert_selector 'p', text: 'Please change your password.'
    fill_in('Password', with: 'Ruddygor39!')
    click_on('Update User')
    assert_selector 'p', text: 'You need to sign in before continuing.'
    fill_in('Email', with: 'paulc@patmos-eng.com')
    fill_in('Password', with: 'Ruddygor39!')
    click_on('Log in')
    assert_selector 'p', text: 'Signed in successfully.'
    STDERR.puts('     A User was successfully created.')
  end


  test "should create a User with signature" do
    STDERR.puts('    Check to see that a User can be created.')
    visit users_url
    assert_selector 'h1', text: 'Users List'
    click_on('New User')
    assert_selector 'h1', text: 'New User'
    fill_in('Email', with: 'paulc@patmos-eng.com')
    fill_in('First Name', with: 'Paul')
    fill_in('Last Name', with: 'Carrick')
    fill_in('Title', with: 'Senior Software Engineer')
    fill_in('Phone', with: '(800) 555-1212')
    fill_in('Password', with: 'Ruddygor38!')
    select("Project Manager", from: "Role")
    attach_file('user_signature_file', Rails.root + 'test/fixtures/files/flowchart.png')
    attach_file('user_profile_picture', Rails.root + 'test/fixtures/files/flowchart.png')
    click_on('Create User')
    assert_selector 'p', text: 'User was successfully created.'
    click_on('Log Out')
    fill_in('Email', with: 'paulc@patmos-eng.com')
    fill_in('Password', with: 'Ruddygor38!')
    click_on('Log in')
    assert_selector 'p', text: 'Signed in successfully.'
    STDERR.puts('     A User was successfully created.')
  end

  test 'should update User' do
    STDERR.puts('    Check to see that a User can be updated.')
    visit users_url
    assert_selector 'h1', text: 'Users List'
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing User'
    fill_in('Title', with: 'Senior Software Engineer')
    fill_in('Phone', with: '(800) 555-1212')
    fill_in('Password', with: 'Ruddygor39!')
    click_on('Update User')
    STDERR.puts('    The User was updated successfully.')
  end

  test 'should delete a User' do
    STDERR.puts('    Check to see a User can be deleted.')
    visit users_url
    assert_selector 'h1', text: 'Users List'
    assert_selector 'a', text: "Delete"
    page.all('a', text: "Delete")[1].click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    STDERR.puts('    The User was successfully deleted.')
  end
end

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.find_by(email: 'test_7@airworthinesscert.com')
  end

  test 'user record should be valid' do
    STDERR.puts('    Check to see that a User Record with required fields filled in is valid.')
    assert_equals(true, @user.valid?, 'User Record',
                  '    Expect User Record to be valid. It was valid.')
    STDERR.puts('    The User Record was valid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create user' do
    STDERR.puts('    Check to see that a User can be created.')
    user = User.new({
                       email:              'paul@patmos-eng.com',
                       encrypted_password: User.new.send(:password_digest, 'Ruddygor38!'),
                       firstname:          'Paul',
                       lastname:           'Carrick',
                       title:              'Software Engineer',
                       phone:              '(360) 622-8065',
                       organization:       'test',
                       organizations:      [ 'test' ],
                       role:               ['Project Manager'],
                       time_zone:          'Pacific Time (US & Canada)',
                       notify_on_changes:  true,
                       fulladmin:          true
                    })

    assert_not_equals_nil(user.save, 'User Record', '    Expect User Record to be created. It was.')
    STDERR.puts('    A User was successfully created.')
  end

  test 'should update user' do
    STDERR.puts('    Check to see that a User can be updated.')

    @user.firstname = 'John'
    @user.lastname  = 'Public'

    assert_not_equals_nil(@user.save, 'User Record', '    Expect User Record to be updated. It was.')
    STDERR.puts('    A User was successfully updated.')
  end

  test 'should delete user' do
    STDERR.puts('    Check to see that a User can be deleted.')
    assert(@user.destroy)
    STDERR.puts('    A User was successfully deleted.')
  end

  test "fullname should return the User's Full name" do
    STDERR.puts("    Check to see that Full name returns the User's name.")
    assert_equals('Restricted View', @user.fullname, 'User Full name', "    Expect User Full name to be 'Restricted View'. It was.")
    STDERR.puts("    fullname successfully returned the user's Full Name.")
  end

  test "to_label should return the User's Full name" do
    STDERR.puts("    Check to see that to_label returns the User's name.")
    assert_equals('Restricted View', @user.to_label, 'User to_label', "    Expect User to_label to be 'Restricted View'. It was.")
    STDERR.puts("    to_label successfully returned the user's Full Name.")
  end

  test "fullname_from_email should return the User's Full name" do
    STDERR.puts("    Check to see that Full name from email returns the User's name.")
    assert_equals('Restricted View', User.fullname_from_email('test_7@airworthinesscert.com'), 'User Full name from email', "    Expect User Full name from email for 'test_7@airworthinesscert.com' to be 'Restricted View'. It was.")
    STDERR.puts("    fullname_from_email successfully returned the user's Full Name.")
  end

  test "organization_or_role should return the User's Full name" do
    STDERR.puts("    Check to see that Organization or Role returns all users.")
    assert_equals(9, User.organization_or_role('test', 'AirWorthinessCert Member').length, 'Organization or Role', "    Expect Organization or Role to return 9 users. It did.")
    STDERR.puts("    organization_or_role successfully returned 9 users.")
  end

  test "remember_me should return false" do
    STDERR.puts("    Check to see that Remember Me returns false.")
    assert_equals(false, @user.remember_me, 'Remeber Me', "    Expect User Remeber Me to return false'. It did.")
    STDERR.puts("    remember_me returned false.")
  end

  test "remember_for should return 30 seconds" do
    STDERR.puts("    Check to see that Remember for returns 30 seconds.")
    assert_equals(30.seconds, @user.remember_for, 'Remeber For', "    Expect User Remember For to return 30 seconds'. It did.")
    STDERR.puts("    remember_for returned 30 seconds.")
  end

  test 'to_csv' do
    STDERR.puts('    Check to see that the User can generate CSV properly.')
    csv        = User.to_csv
    lines      = csv.split("\n")

    assert_equals('id,email,encrypted_password',
                  lines[0],
                  'First Line',
                  '    Expect First Line to be "id,email,encrypted_password". It was.')
    STDERR.puts('    The User generated CSV successfully.')
  end

  test 'current user' do
    STDERR.puts('    Check to see that the Current User returns the current user.')

    attributes   = [
                      'email',
                      'encrypted_password',
                      'firstname',
                      'lastname',
                      'title',
                      'phone',
                      'organization',
                      'time_zone',
                      'notify_on_changes',
                      'fulladmin'
                   ]
    User.current = @user

    assert(compare_records(@user, User.current, attributes))
    STDERR.puts('    The User Current User returned the current user.')
  end

  test 'current organization' do
    STDERR.puts('    Check to see that the Current Organization returns the current organization.')

    User.current_organization = 'test'

    assert_equals('test', User.current_organization, 'Current Organization', "    Expect Current Organization to be 'test'. It was.")
    STDERR.puts('    The User Current Organization returned the current organization.')
  end

  test 'parse_name' do
    STDERR.puts('    Check to see that the Parse Name parses the name correctly.')

    name = 'Paul Jeffrey Carrick'

    assert(User.is_name?(name))
    assert_equals('Paul Jeffrey Carrick', User.parse_name(name),
                  'Parsed Name',
                  "    Expect Original parsed name to be 'Paul Jeffrey Carrick'. It was.")
    assert_equals('Paul', User.parse_name(name, :first_name),
                  'Parsed Name',
                  "    Expect First parsed name to be 'Paul'. It was.")
    assert_equals('Carrick', User.parse_name(name, :last_name),
                  'Parsed Name',
                  "    Expect Last parsed name to be 'Carrick'. It was.")
    assert_equals('Jeffrey', User.parse_name(name, :middle_name),
                  'Parsed Name',
                  "    Expect Middle parsed name to be 'Jeffrey'. It was.")
    assert_equals('Paul Carrick', User.parse_name(name, :first_and_last_name),
                  'Parsed Name',
                  "    Expect First and Last parsed name to be 'Paul Carrick'. It was.")

    name = 'Carrick, Paul Jeffrey'

    assert(User.is_name?(name))
    assert_equals('Carrick, Paul Jeffrey', User.parse_name(name),
                  'Parsed Name',
                  "    Expect Reversed Original parsed name to be 'Paul Jeffrey Carrick'. It was.")
    assert_equals('Paul', User.parse_name(name, :first_name, true),
                  'Parsed Name',
                  "    Expect Reversed First parsed name to be 'Paul'. It was.")
    assert_equals('Carrick,', User.parse_name(name, :last_name, true),
                  'Parsed Name',
                  "    Expect Reversed Last parsed name to be 'Carrick'. It was.")
    assert_equals('Jeffrey', User.parse_name(name, :middle_name, true),
                  'Parsed Name',
                  "    Expect Reversed Middle parsed name to be 'Jeffrey'. It was.")
    assert_equals('Paul Carrick,',
                  User.parse_name(name, :first_and_last_name, true),
                  'Parsed Name',
                  "    Expect Reversed First and Last parsed name to be 'Paul Carrick'. It was.")
    STDERR.puts('    Parse Name parsed the name correctly.')
  end
end

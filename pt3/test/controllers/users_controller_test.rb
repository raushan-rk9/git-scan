require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Users List Page can be loaded.')
    get users_url
    assert_response :success
    STDERR.puts('    The Users List Page loaded successfully.')
  end

  test "should show user" do
    STDERR.puts('    Check to see that a Show User Page can be loaded.')
    get user_url(@user)
    assert_response :success
    STDERR.puts('    The Show User Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a New User Page can be loaded.')
    get new_user_url
    assert_response :success
    STDERR.puts('    The New User Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit User Page can be loaded.')
    get edit_user_url(@user)
    assert_response :success
    STDERR.puts('    The Edit User Page loaded successfully.')
  end

  test "should create user" do
    STDERR.puts('    Check to see that a User can be created.')

    assert_difference('User.count') do
      post(users_url,
           params:
           {
              user:
              {
                 email:              'paulc@patmos-eng.com',
                 password:            'Ruddygor38!',
                 firstname:          'Paul J.',
                 lastname:           'Carrick',
                 title:              'Software Engineer',
                 phone:              '(360) 622-8065',
                 organization:       'test',
                 organizations:      [ 'test' ],
                 role:               ['Project Manager'],
                 time_zone:          'Pacific Time (US & Canada)',
                 notify_on_changes:  true,
                 fulladmin:          true
              }
           })
    end

    assert_redirected_to user_url(User.last)

    STDERR.puts('    The User was created successfully.')
  end

  test "should update user" do
    STDERR.puts('    Check to see that a User can be updated.')

    patch user_url(@user),
          params:
          {
             user:
             {
                email:              @user.email,
                encrypted_password: User.new.send(:password_digest,
                                                  @user.password),
                firstname:          @user.firstname,
                lastname:           @user.lastname,
                title:              @user.title,
                phone:              @user.phone,
                organization:       @user.organization,
                organizations:      @user.organizations,
                role:               @user.role,
                time_zone:          @user.time_zone,
                notify_on_changes:  @user.notify_on_changes,
                fulladmin:          @user.fulladmin
             }
          }
    assert_redirected_to user_url(@user)

    STDERR.puts('    The User was updated successfully.')
  end

  test "should destroy user" do
    STDERR.puts('    Check to see that a User can be deleted.')

    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url

    STDERR.puts('    The User was deleted successfully.')
  end

  test "should switch organization" do
    STDERR.puts('    Check to see that a User Switch Organization Page can be loaded.')
    get edit_user_url(@user)
    assert_response :success
    STDERR.puts('    The Edit User Switch Organization Page loaded successfully.')
  end

  test "should set organization" do
    STDERR.puts('    Check to see that an Organization can be set.')
    get user_set_organization_url(@user, organization: 'test')
    assert_response :success
    STDERR.puts('    A Organization was set successfully.')
  end
end

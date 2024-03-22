require 'test_helper'

class LicenseesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @licensee = Licensee.find_by(identifier: 'test')

    user_admin
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Licensee List Page can be loaded.')
    get licensees_url
    assert_response :success
    STDERR.puts('    The Licensee List Page loaded successfully.')
  end

  test "should show licensee" do
    STDERR.puts('    Check to see that the Licensee can be viewed.')
    get licensee_url(@licensee)
    assert_response :success
    STDERR.puts('    The Licensee was viewed successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the new Licensee Page can be loaded.')
    get new_licensee_url
    assert_response :success
    STDERR.puts('    The new Licensee Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the edit Licensee Page can be loaded.')
    get edit_licensee_url(@licensee)
    assert_response :success
    STDERR.puts('    The edit Licensee Page loaded successfully.')
  end

  test "should create licensee" do
    STDERR.puts('    Check to see that a new Licensee can be created.')

    assert_difference('Licensee.count') do
      post licensees_url,
        params:
        {
          licensee:
          {
             identifier:     @licensee.identifier + '2',
             name:           @licensee.name,
             setup_date:     @licensee.setup_date,
             license_date:   @licensee.license_date,
             renewal_date:   @licensee.renewal_date,
             administrator:  @licensee.administrator,
             contact_emails: @licensee.contact_emails.join(',')
          }
        }
    end

    assert_redirected_to licensee_url(Licensee.last)
    STDERR.puts('    A new Licensee was created.')
  end

  test "should update licensee" do
    STDERR.puts('    Check to see that a new Licensee can be updated.')

    patch licensee_url(@licensee),
      params:
      {
        licensee:
        {
           identifier:     @licensee.identifier + '2',
           name:           @licensee.name,
           setup_date:     @licensee.setup_date,
           license_date:   @licensee.license_date,
           renewal_date:   @licensee.renewal_date,
           administrator:  @licensee.administrator,
           contact_emails: @licensee.contact_emails.join(',')
        }
      }

    assert_redirected_to licensee_url(@licensee)
    STDERR.puts('    A Licensee was updated.')
  end

  test "should destroy licensee" do
    STDERR.puts('    Check to see that a Licensee can be deleted.')

    assert_difference('Licensee.count', -1) do
      delete licensee_url(@licensee)
    end

    assert_redirected_to licensees_url
    STDERR.puts('    A Licensee was deleted.')
  end
end

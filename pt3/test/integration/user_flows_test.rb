require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  test "login and browse site" do
    sign_in users(:user_admin)
    get "/projects"
    assert_response :success
    assert_select 'h1', 'Projects'
    assert_equal '/projects', path

    # Continue with other assertions
  end

  private

end
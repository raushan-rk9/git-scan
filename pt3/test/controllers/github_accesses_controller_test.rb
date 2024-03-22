require 'test_helper'

class GithubAccessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @github_access = github_access(:one)
  end

  test "should get index" do
    get github_accesses_url
    assert_response :success
  end

  test "should get new" do
    get new_github_accesses_url
    assert_response :success
  end

  test "should create github_access" do
    assert_difference('GithubAccess.count') do
      post github_accesses_url, params: { github_access: { id: @github_access.id, password: @github_access.password, token: @github_access.token, user_id: @github_access.user_id, username: @github_access.username } }
    end

    assert_redirected_to github_accesses_url(GithubAccess.last)
  end

  test "should show github_access" do
    get github_accesses_url(@github_access)
    assert_response :success
  end

  test "should get edit" do
    get edit_github_accesses_url(@github_access)
    assert_response :success
  end

  test "should update github_access" do
    patch github_accesses_url(@github_access), params: { github_access: { id: @github_access.id, password: @github_access.password, token: @github_access.token, user_id: @github_access.user_id, username: @github_access.username } }
    assert_redirected_to github_accesses_url(@github_access)
  end

  test "should destroy github_access" do
    assert_difference('GithubAccess.count', -1) do
      delete github_accesses_url(@github_access)
    end

    assert_redirected_to github_accesses_url
  end
end

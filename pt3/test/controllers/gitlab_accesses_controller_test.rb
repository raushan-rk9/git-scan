require 'test_helper'

class GitlabAccessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @gitlab_access = gitlab_accesses(:one)
  end

  test "should get index" do
    get gitlab_accesses_url
    assert_response :success
  end

  test "should get new" do
    get new_gitlab_access_url
    assert_response :success
  end

  test "should create gitlab_access" do
    assert_difference('GitlabAccess.count') do
      post gitlab_accesses_url, params: { gitlab_access: {  } }
    end

    assert_redirected_to gitlab_access_url(GitlabAccess.last)
  end

  test "should show gitlab_access" do
    get gitlab_access_url(@gitlab_access)
    assert_response :success
  end

  test "should get edit" do
    get edit_gitlab_access_url(@gitlab_access)
    assert_response :success
  end

  test "should update gitlab_access" do
    patch gitlab_access_url(@gitlab_access), params: { gitlab_access: {  } }
    assert_redirected_to gitlab_access_url(@gitlab_access)
  end

  test "should destroy gitlab_access" do
    assert_difference('GitlabAccess.count', -1) do
      delete gitlab_access_url(@gitlab_access)
    end

    assert_redirected_to gitlab_accesses_url
  end
end

require 'test_helper'

class ProjectAccessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project_access = project_accesses(:one)
  end

  test "should get index" do
    get project_accesses_url
    assert_response :success
  end

  test "should get new" do
    get new_project_access_url
    assert_response :success
  end

  test "should create project_access" do
    assert_difference('ProjectAccess.count') do
      post project_accesses_url, params: { project_access: { access: @project_access.access, project_id: @project_access.project_id, user_id: @project_access.user_id } }
    end

    assert_redirected_to project_access_url(ProjectAccess.last)
  end

  test "should show project_access" do
    get project_access_url(@project_access)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_access_url(@project_access)
    assert_response :success
  end

  test "should update project_access" do
    patch project_access_url(@project_access), params: { project_access: { access: @project_access.access, project_id: @project_access.project_id, user_id: @project_access.user_id } }
    assert_redirected_to project_access_url(@project_access)
  end

  test "should destroy project_access" do
    assert_difference('ProjectAccess.count', -1) do
      delete project_access_url(@project_access)
    end

    assert_redirected_to project_accesses_url
  end
end

require "application_system_test_case"

class ProjectAccessesTest < ApplicationSystemTestCase
  setup do
    @project_access = project_accesses(:one)
  end

  test "visiting the index" do
    visit project_accesses_url
    assert_selector "h1", text: "Project Accesses"
  end

  test "creating a Project access" do
    visit project_accesses_url
    click_on "New Project Access"

    fill_in "Access", with: @project_access.access
    fill_in "Project", with: @project_access.project_id
    fill_in "User", with: @project_access.user_id
    click_on "Create Project access"

    assert_text "Project access was successfully created"
    click_on "Back"
  end

  test "updating a Project access" do
    visit project_accesses_url
    click_on "Edit", match: :first

    fill_in "Access", with: @project_access.access
    fill_in "Project", with: @project_access.project_id
    fill_in "User", with: @project_access.user_id
    click_on "Update Project access"

    assert_text "Project access was successfully updated"
    click_on "Back"
  end

  test "destroying a Project access" do
    visit project_accesses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Project access was successfully destroyed"
  end
end

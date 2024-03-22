require "application_system_test_case"

class GithubAccessesTest < ApplicationSystemTestCase
  setup do
    @github_access = github_access(:one)
  end

  test "visiting the index" do
    visit github_accesses_url
    assert_selector "h1", text: "Github Credentials"
  end

  test "creating a Github credential" do
    visit github_accesses_url
    click_on "New Github Credential"

    fill_in "Id", with: @github_access.id
    fill_in "Password", with: @github_access.password
    fill_in "Token", with: @github_access.token
    fill_in "User", with: @github_access.user_id
    fill_in "Username", with: @github_access.username
    click_on "Create Github credential"

    assert_text "Github credential was successfully created"
    click_on "Back"
  end

  test "updating a Github credential" do
    visit github_accesses_url
    click_on "Edit", match: :first

    fill_in "Id", with: @github_access.id
    fill_in "Password", with: @github_access.password
    fill_in "Token", with: @github_access.token
    fill_in "User", with: @github_access.user_id
    fill_in "Username", with: @github_access.username
    click_on "Update Github credential"

    assert_text "Github credential was successfully updated"
    click_on "Back"
  end

  test "destroying a Github credential" do
    visit github_accesses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Github credential was successfully destroyed"
  end
end

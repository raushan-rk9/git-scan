require "application_system_test_case"

class GitlabAccessesTest < ApplicationSystemTestCase
  setup do
    @gitlab_access = gitlab_accesses(:one)
  end

  test "visiting the index" do
    visit gitlab_accesses_url
    assert_selector "h1", text: "Gitlab Accesses"
  end

  test "creating a Gitlab access" do
    visit gitlab_accesses_url
    click_on "New Gitlab Access"

    click_on "Create Gitlab access"

    assert_text "Gitlab access was successfully created"
    click_on "Back"
  end

  test "updating a Gitlab access" do
    visit gitlab_accesses_url
    click_on "Edit", match: :first

    click_on "Update Gitlab access"

    assert_text "Gitlab access was successfully updated"
    click_on "Back"
  end

  test "destroying a Gitlab access" do
    visit gitlab_accesses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Gitlab access was successfully destroyed"
  end
end

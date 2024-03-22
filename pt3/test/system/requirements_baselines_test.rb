require "application_system_test_case"

class RequirementsBaselinesTest < ApplicationSystemTestCase
  setup do
    @requirements_baseline = requirements_baselines(:one)
  end

  test "visiting the index" do
    visit requirements_baselines_url
    assert_selector "h1", text: "Requirements Baselines"
  end

  test "creating a Requirements baseline" do
    visit requirements_baselines_url
    click_on "New Requirements Baseline"

    fill_in "Archive type", with: @requirements_baseline.archive_type
    fill_in "Archived at", with: @requirements_baseline.archived_at
    fill_in "Description", with: @requirements_baseline.description
    fill_in "Full", with: @requirements_baseline.full_id
    fill_in "Name", with: @requirements_baseline.name
    fill_in "Organization", with: @requirements_baseline.organization
    fill_in "Pact version", with: @requirements_baseline.pact_version
    fill_in "Project", with: @requirements_baseline.project_id
    fill_in "Revision", with: @requirements_baseline.revision
    fill_in "Version", with: @requirements_baseline.version
    click_on "Create Requirements baseline"

    assert_text "Requirements baseline was successfully created"
    click_on "Back"
  end

  test "updating a Requirements baseline" do
    visit requirements_baselines_url
    click_on "Edit", match: :first

    fill_in "Archive type", with: @requirements_baseline.archive_type
    fill_in "Archived at", with: @requirements_baseline.archived_at
    fill_in "Description", with: @requirements_baseline.description
    fill_in "Full", with: @requirements_baseline.full_id
    fill_in "Name", with: @requirements_baseline.name
    fill_in "Organization", with: @requirements_baseline.organization
    fill_in "Pact version", with: @requirements_baseline.pact_version
    fill_in "Project", with: @requirements_baseline.project_id
    fill_in "Revision", with: @requirements_baseline.revision
    fill_in "Version", with: @requirements_baseline.version
    click_on "Update Requirements baseline"

    assert_text "Requirements baseline was successfully updated"
    click_on "Back"
  end

  test "destroying a Requirements baseline" do
    visit requirements_baselines_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Requirements baseline was successfully destroyed"
  end
end

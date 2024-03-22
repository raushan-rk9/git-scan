require "application_system_test_case"

class SpecObjectsTest < ApplicationSystemTestCase
  setup do
    @spec_object = spec_objects(:one)
  end

  test "visiting the index" do
    visit spec_objects_url
    assert_selector "h1", text: "Spec Objects"
  end

  test "creating a Spec object" do
    visit spec_objects_url
    click_on "New Spec Object"

    fill_in "Data", with: @spec_object.data
    fill_in "Type", with: @spec_object.type
    fill_in "Value", with: @spec_object.value
    click_on "Create Spec object"

    assert_text "Spec object was successfully created"
    click_on "Back"
  end

  test "updating a Spec object" do
    visit spec_objects_url
    click_on "Edit", match: :first

    fill_in "Data", with: @spec_object.data
    fill_in "Type", with: @spec_object.type
    fill_in "Value", with: @spec_object.value
    click_on "Update Spec object"

    assert_text "Spec object was successfully updated"
    click_on "Back"
  end

  test "destroying a Spec object" do
    visit spec_objects_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Spec object was successfully destroyed"
  end
end

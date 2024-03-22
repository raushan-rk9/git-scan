require "application_system_test_case"

class CodeCheckmarksTest < ApplicationSystemTestCase
  setup do
    @code_checkmark = code_checkmarks(:one)
  end

  test "visiting the index" do
    visit code_checkmarks_url
    assert_selector "h1", text: "Code Checkmarks"
  end

  test "creating a Code checkmark" do
    visit code_checkmarks_url
    click_on "New Code Checkmark"

    fill_in "Checkmark", with: @code_checkmark.checkmark_id
    fill_in "Filename", with: @code_checkmark.filename
    fill_in "Line number", with: @code_checkmark.line_number
    fill_in "Source code", with: @code_checkmark.source_code_id
    click_on "Create Code checkmark"

    assert_text "Code checkmark was successfully created"
    click_on "Back"
  end

  test "updating a Code checkmark" do
    visit code_checkmarks_url
    click_on "Edit", document_parms: :first

    fill_in "Checkmark", with: @code_checkmark.checkmark_id
    fill_in "Filename", with: @code_checkmark.filename
    fill_in "Line number", with: @code_checkmark.line_number
    fill_in "Source code", with: @code_checkmark.source_code_id
    click_on "Update Code checkmark"

    assert_text "Code checkmark was successfully updated"
    click_on "Back"
  end

  test "destroying a Code checkmark" do
    visit code_checkmarks_url
    page.accept_confirm do
      click_on "Destroy", document_parms: :first
    end

    assert_text "Code checkmark was successfully destroyed"
  end
end

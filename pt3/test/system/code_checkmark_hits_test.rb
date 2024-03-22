require "application_system_test_case"

class CodeCheckmarkHitsTest < ApplicationSystemTestCase
  setup do
    @code_checkmark_hit = code_checkmark_hits(:one)
  end

  test "visiting the index" do
    visit code_checkmark_hits_url
    assert_selector "h1", text: "Code Checkmark Hits"
  end

  test "creating a Code checkmark hit" do
    visit code_checkmark_hits_url
    click_on "New Code Checkmark Hit"

    fill_in "Code checkmark", with: @code_checkmark_hit.code_checkmark_id
    fill_in "Hit at", with: @code_checkmark_hit.hit_at
    click_on "Create Code checkmark hit"

    assert_text "Code checkmark hit was successfully created"
    click_on "Back"
  end

  test "updating a Code checkmark hit" do
    visit code_checkmark_hits_url
    click_on "Edit", document_parms: :first

    fill_in "Code checkmark", with: @code_checkmark_hit.code_checkmark_id
    fill_in "Hit at", with: @code_checkmark_hit.hit_at
    click_on "Update Code checkmark hit"

    assert_text "Code checkmark hit was successfully updated"
    click_on "Back"
  end

  test "destroying a Code checkmark hit" do
    visit code_checkmark_hits_url
    page.accept_confirm do
      click_on "Destroy", document_parms: :first
    end

    assert_text "Code checkmark hit was successfully destroyed"
  end
end

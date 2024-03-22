require "application_system_test_case"

class ModuleDescriptionsTest < ApplicationSystemTestCase
  setup do
    @project          = Project.find_by(identifier: 'TEST')
    @hardware_item    = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item    = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @software_mds_001 = ModuleDescription.find_by(item_id: @software_item.id,
                                                  full_id: 'MD-001')
    @software_mds_002 = ModuleDescription.find_by(item_id: @software_item.id,
                                                  full_id: 'MD-002')
    @hardware_mds_005 = ModuleDescription.find_by(item_id: @hardware_item.id,
                                                  full_id: 'MD-005')
    @hardware_mds_005 = ModuleDescription.find_by(item_id: @hardware_item.id,
                                                  full_id: 'MD-006')

    user_pm
  end

  test "visiting the index" do
    visit item_module_descriptions_url(@software_item)
    assert_selector "h1", text: "Module Descriptions"
  end

  test "creating a Module description" do
    visit item_module_descriptions_url(@software_item)

    click_on "New Module Description"

    fill_in "Archive", with: @module_description.archive
    fill_in "Description", with: @module_description.description
    fill_in "Draft revision", with: @module_description.draft_revision
    fill_in "File name", with: @module_description.file_name
    fill_in "Full", with: @module_description.full_id
    fill_in "High level requirement associations", with: @module_description.high_level_requirement_associations
    fill_in "Item", with: @module_description.item
    fill_in "Low level requirement associations", with: @module_description.low_level_requirement_associations
    fill_in "Module description number", with: @module_description.module_description_number
    fill_in "Project", with: @module_description.project
    fill_in "Revision", with: @module_description.revision
    fill_in "Revision date", with: @module_description.revision_date
    check "Soft delete" if @module_description.soft_delete
    fill_in "Version", with: @module_description.version
    click_on "Create Module description"

    assert_text "Module description was successfully created"
    click_on "Back"
  end

  test "updating a Module description" do
    visit item_module_descriptions_url(@software_item)

    click_on "Edit", match: :first

    fill_in "Archive", with: @module_description.archive
    fill_in "Description", with: @module_description.description
    fill_in "Draft revision", with: @module_description.draft_revision
    fill_in "File name", with: @module_description.file_name
    fill_in "Full", with: @module_description.full_id
    fill_in "High level requirement associations", with: @module_description.high_level_requirement_associations
    fill_in "Item", with: @module_description.item
    fill_in "Low level requirement associations", with: @module_description.low_level_requirement_associations
    fill_in "Module description number", with: @module_description.module_description_number
    fill_in "Project", with: @module_description.project
    fill_in "Revision", with: @module_description.revision
    fill_in "Revision date", with: @module_description.revision_date
    check "Soft delete" if @module_description.soft_delete
    fill_in "Version", with: @module_description.version
    click_on "Update Module description"

    assert_text "Module description was successfully updated"
    click_on "Back"
  end

  test "destroying a Module description" do
    visit item_module_descriptions_url(@software_item)

    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Module description was successfully destroyed"
  end
end

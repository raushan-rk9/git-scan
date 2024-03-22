require 'test_helper'

class ModuleDescriptionsControllerTest < ActionDispatch::IntegrationTest
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

    @module_description = @software_mds_001
  end

  test "should get index" do
    get item_module_descriptions_url(@software_item)
    assert_response :success
  end

  test "should get new" do
    get new_item_module_description_url(@software_item)
    assert_response :success
  end

  test "should create module_description" do
    assert_difference('ModuleDescription.count') do
      post item_module_descriptions_url(@software_item),
           params: {
                      module_description: {
                                             archive_id:                          @module_description.archive_id,
                                             description:                         @module_description.description,
                                             draft_revision:                      @module_description.draft_revision,
                                             file_name:                           @module_description.file_name,
                                             full_id:                             @module_description.full_id + '_2',
                                             high_level_requirement_associations: @module_description.high_level_requirement_associations,
                                             item_id:                             @module_description.item_id,
                                             low_level_requirement_associations:  @module_description.low_level_requirement_associations,
                                             module_description_number:           @module_description.module_description_number + 100,
                                             project_id:                          @module_description.project_id,
                                             revision:                            @module_description.revision,
                                             revision_date:                       @module_description.revision_date,
                                             soft_delete:                         @module_description.soft_delete,
                                             version:                             @module_description.version
                                          }
                    }
    end

    assert_redirected_to item_module_description_url(@software_item,
                                                     ModuleDescription.last)
  end

  test "should show module_description" do
    get item_module_description_url(@software_item, @module_description)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_module_description_url(@software_item, @module_description)
    assert_response :success
  end

  test "should update module_description" do
    patch item_module_description_url(@software_item, @module_description),
          params: {
                      module_description: {
                                             archive_id:                          @module_description.archive_id,
                                             description:                         @module_description.description,
                                             draft_revision:                      @module_description.draft_revision,
                                             file_name:                           @module_description.file_name,
                                             full_id:                             @module_description.full_id + '_3',
                                             high_level_requirement_associations: @module_description.high_level_requirement_associations,
                                             item_id:                             @module_description.item_id,
                                             low_level_requirement_associations:  @module_description.low_level_requirement_associations,
                                             module_description_number:           @module_description.module_description_number,
                                             project_id:                          @module_description.project_id,
                                             revision:                            @module_description.revision,
                                             revision_date:                       @module_description.revision_date,
                                             soft_delete:                         @module_description.soft_delete,
                                             version:                             @module_description.version
                                          }
                    }
    assert_redirected_to item_module_description_url(@software_item, @module_description, previous_mode: 'editing')
  end

  test "should destroy module_description" do
    assert_difference('ModuleDescription.count', -1) do
      delete item_module_description_url(@software_item, @module_description)
    end

    assert_redirected_to item_module_descriptions_url(@software_item)
  end
end

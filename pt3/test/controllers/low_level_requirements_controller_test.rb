require 'test_helper'

class LowLevelRequirementsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project          = Project.find_by(identifier: 'TEST')
    @hardware_item    = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item    = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_llr_001 = LowLevelRequirement.find_by(item_id: @hardware_item.id,
                                                     full_id: 'LLR-001')
    @hardware_llr_002 = LowLevelRequirement.find_by(item_id: @hardware_item.id,
                                                     full_id: 'LLR-002')
    @software_llr_001 = LowLevelRequirement.find_by(item_id: @software_item.id,
                                                     full_id: 'LLR-001')
    @software_llr_002 = LowLevelRequirement.find_by(item_id: @software_item.id,
                                                     full_id: 'LLR-002')
    @model_file       = ModelFile.find_by(full_id: 'MF-001')
    @file_data        = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                     'image/png',
                                                     true)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Low Level Requirements List Page can be loaded.')
    get item_low_level_requirements_url(@hardware_item)
    assert_response :success
    STDERR.puts('    The Low Level Requirements List Page loaded successfully.')
  end

  test "should show low level requirement" do
    STDERR.puts('    Check to see that a Low Level Requirement can be viewed.')
    get item_low_level_requirement_url(@hardware_item, @hardware_llr_001)
    assert_response :success
    STDERR.puts('    The Low Level Requirement view loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Low Level Requirements Page can be loaded.')
    get new_item_low_level_requirement_url(@hardware_item)
    assert_response :success
    STDERR.puts('    A new Low Level Requirements Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit Low Level Requirement Page can be loaded.')
    get edit_item_low_level_requirement_url(@hardware_item, @hardware_llr_001)
    assert_response :success
    STDERR.puts('    The Edit Low Level Requirement page loaded successfully.')
  end

  test "should create low level requirement" do
    STDERR.puts('    Check to see that a Low Level Requirement can be created.')

    assert_difference('LowLevelRequirement.count') do
      post item_low_level_requirements_url(@hardware_item),
        params:
        {
          low_level_requirement:
          {
            reqid:                               @hardware_llr_001.reqid + 3,
            full_id:                             'LLR-004',
            description:                         @hardware_llr_001.description,
            category:                            @hardware_llr_001.category,
            verification_method:                 @hardware_llr_001.verification_method,
            safety:                              @hardware_llr_001.safety,
            derived:                             @hardware_llr_001.derived,
            version:                             @hardware_llr_001.version,
            item_id:                             @hardware_llr_001.item_id,
            project_id:                          @hardware_llr_001.project_id,
            derived_justification:               @hardware_llr_001.derived_justification,
            organization:                        @hardware_llr_001.organization,
            archive_id:                          @hardware_llr_001.archive_id,
            high_level_requirement_associations: @hardware_llr_001.high_level_requirement_associations,
            soft_delete:                         @hardware_llr_001.soft_delete,
            document_id:                         @hardware_llr_001.document_id,
            model_file_id:                       @hardware_llr_001.model_file_id
          }
        }
    end

    assert_redirected_to item_low_level_requirement_url(@hardware_item, LowLevelRequirement.last)
    STDERR.puts('    The Low Level Requirement was created successfully.')
  end

  test "should update low level requirement" do
    STDERR.puts('    Check to see that a Low Level Requirement can be updated.')

    patch item_low_level_requirement_url(@hardware_item, @hardware_llr_001),
      params:
      {
        low_level_requirement:
        {
            reqid:                               @hardware_llr_001.reqid + 3,
            full_id:                             'LLR-004',
            description:                         @hardware_llr_001.description,
            category:                            @hardware_llr_001.category,
            verification_method:                 @hardware_llr_001.verification_method,
            safety:                              @hardware_llr_001.safety,
            derived:                             @hardware_llr_001.derived,
            version:                             @hardware_llr_001.version,
            item_id:                             @hardware_llr_001.item_id,
            project_id:                          @hardware_llr_001.project_id,
            derived_justification:               @hardware_llr_001.derived_justification,
            organization:                        @hardware_llr_001.organization,
            archive_id:                          @hardware_llr_001.archive_id,
            high_level_requirement_associations: @hardware_llr_001.high_level_requirement_associations,
            soft_delete:                         @hardware_llr_001.soft_delete,
            document_id:                         @hardware_llr_001.document_id,
            model_file_id:                       @hardware_llr_001.model_file_id
        }
      }

    assert_redirected_to item_low_level_requirement_url(@hardware_item, @hardware_llr_001, previous_mode: 'editing')
    STDERR.puts('    The Low Level Requirement was successfully updated.')
  end

  test "should destroy low level requirement" do
    STDERR.puts('    Check to see that a Low Level Requirement can be deleted.')

    assert_difference('LowLevelRequirement.count', -1) do
      delete item_low_level_requirement_url(@hardware_item, @hardware_llr_001)
    end

    assert_redirected_to item_low_level_requirements_url(@hardware_item)
    STDERR.puts('    The Low Level Requirement was successfully deleted.')
  end

  test "should export low level requirements" do
    STDERR.puts('    Check to see that a Low Level Requirement can be exported.')
    get item_low_level_requirements_export_url(@hardware_item)
    assert_response :success

    post item_low_level_requirements_export_url(@hardware_item),
      params:
      {
        llr_export:
        {
          export_type: 'CSV'
        }
      }

    assert_redirected_to item_low_level_requirements_export_url(@hardware_item, :format => :csv)
    get item_low_level_requirements_export_url(@hardware_item, :format => :csv)
    assert_response :success

    lines = response.body.split("\n")

    assert_equals('id,reqid,full_id,description,derived,version,item_id,project_id,high_level_requirement_associations,derived_justification,created_at,updated_at,organization,category,verification_method,safety,soft_delete,document_id,model_file_id,archive_revision,archive_version',
                  lines[0], 'Header',
                  "    Expect Header to be 'id,reqid,full_id,description,derived,version,item_id,project_id,high_level_requirement_associations,derived_justification,created_at,updated_at,organization,category,verification_method,safety,soft_delete,document_id,model_file_id,archive_revision,archive_version'. It was...")

    get item_low_level_requirements_export_url(@hardware_item)
    assert_response :success

    post item_low_level_requirements_export_url(@hardware_item),
      params:
      {
        llr_export:
        {
          export_type: 'PDF'
        }
      }

    assert_redirected_to item_low_level_requirements_export_url(@hardware_item, :format => :pdf)
    get item_low_level_requirements_export_url(@hardware_item, :format => :pdf)
    assert_response :success
    assert_between(18000, 24000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 18000 and 24000.")
    get item_low_level_requirements_export_url(@hardware_item)
    assert_response :success

    post item_low_level_requirements_export_url(@hardware_item),
      params:
      {
        llr_export:
        {
          export_type: 'XLS'
        }
      }

    assert_redirected_to item_low_level_requirements_export_url(@hardware_item, :format => :xls)
    get item_low_level_requirements_export_url(@hardware_item, :format => :xls)
    assert_response :success
    assert_equals(true, ((response.body.length > 5000) && (response.body.length < 6000)), 'XLS Download Length', "    Expect XLS download length to be > 5000. It was...")
    get item_low_level_requirements_export_url(@hardware_item)
    assert_response :success

    post item_low_level_requirements_export_url(@hardware_item),
      params:
      {
        llr_export:
        {
          export_type: 'HTML'
        }
      }

    assert_response :success
    STDERR.puts('    A Low Level Requirement was exported.')
  end

  test "should import low level requirements" do
    STDERR.puts('    Check to see that a Low Level Requirement file can be imported.')
    get item_low_level_requirements_import_url(@hardware_item)
    assert_response :success

    post item_low_level_requirements_import_url(@hardware_item),
      params:
      {
        '/import' =>
        {
          item_select:                   @hardware_item.id,
          duplicates_permitted:          '1',
          association_changes_permitted: '1',
          file:                          fixture_file_upload('files/Hardware Item-Low_Level_Requirements.csv')
        }
      }

    assert_redirected_to item_low_level_requirements_url(@hardware_item)
    STDERR.puts('    A Low Level Requirement file was imported.')
  end

  test "should renumber" do
    STDERR.puts('    Check to see that the Low Level Requirements can be renumbered.')
    get item_low_level_requirements_renumber_url(@hardware_item)
    assert_redirected_to item_low_level_requirements_url(@hardware_item)
    STDERR.puts('    The Low Level Requirements were successful renumbered.')
  end

  test "should mark as deleted" do
    STDERR.puts('    Check to see that the Low Level Requirements can be marked as deleted.')
    get item_low_level_requirement_mark_as_deleted_url(@hardware_item, @hardware_llr_001)
    assert_redirected_to item_low_level_requirements_url(@hardware_item)
    STDERR.puts('    The Low Level Requirements was successfully marked as deleted.')
  end
end

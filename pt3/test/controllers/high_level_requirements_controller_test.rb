require 'test_helper'

class HighLevelRequirementsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project          = Project.find_by(identifier: 'TEST')
    @hardware_item    = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item    = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_hlr_001 = HighLevelRequirement.find_by(item_id: @hardware_item.id,
                                                     full_id: 'HLR-001')
    @hardware_hlr_002 = HighLevelRequirement.find_by(item_id: @hardware_item.id,
                                                     full_id: 'HLR-002')
    @software_hlr_001 = HighLevelRequirement.find_by(item_id: @software_item.id,
                                                     full_id: 'HLR-001')
    @software_hlr_002 = HighLevelRequirement.find_by(item_id: @software_item.id,
                                                     full_id: 'HLR-002')
    @model_file       = ModelFile.find_by(full_id: 'MF-001')
    @file_data        = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                     'image/png',
                                                     true)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the High Level Requirements List Page can be loaded.')
    get item_high_level_requirements_url(@hardware_item)
    assert_response :success
    STDERR.puts('    The High Level Requirements List Page loaded successfully.')
  end

  test "should show high level requirement" do
    STDERR.puts('    Check to see that a High Level Requirement can be viewed.')
    get item_high_level_requirement_url(@hardware_item, @hardware_hlr_001)
    assert_response :success
    STDERR.puts('    The High Level Requirement view loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new High Level Requirements Page can be loaded.')
    get new_item_high_level_requirement_url(@hardware_item)
    assert_response :success
    STDERR.puts('    A new High Level Requirements Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit High Level Requirement Page can be loaded.')
    get edit_item_high_level_requirement_url(@hardware_item, @hardware_hlr_001)
    assert_response :success
    STDERR.puts('    The Edit High Level Requirement page loaded successfully.')
  end

  test "should create high level requirement" do
    STDERR.puts('    Check to see that a High Level Requirement can be created.')

    assert_difference('HighLevelRequirement.count') do
      post item_high_level_requirements_url(@hardware_item),
        params:
        {
          high_level_requirement:
          {
            reqid:                               @hardware_hlr_001.reqid + 3,
            full_id:                             'HLR-004',
            description:                         @hardware_hlr_001.description,
            category:                            @hardware_hlr_001.category,
            verification_method:                 @hardware_hlr_001.verification_method,
            safety:                              @hardware_hlr_001.safety,
            robustness:                          @hardware_hlr_001.robustness,
            derived:                             @hardware_hlr_001.derived,
            testmethod:                          @hardware_hlr_001.testmethod,
            version:                             @hardware_hlr_001.version,
            item_id:                             @hardware_hlr_001.item_id,
            project_id:                          @hardware_hlr_001.project_id,
            system_requirement_associations:     @hardware_hlr_001.system_requirement_associations,
            derived_justification:               @hardware_hlr_001.derived_justification,
            organization:                        @hardware_hlr_001.organization,
            archive_id:                          @hardware_hlr_001.archive_id,
            high_level_requirement_associations: @hardware_hlr_001.high_level_requirement_associations,
            soft_delete:                         @hardware_hlr_001.soft_delete,
            document_id:                         @hardware_hlr_001.document_id,
            model_file_id:                       @hardware_hlr_001.model_file_id
          }
        }
    end

    assert_redirected_to item_high_level_requirement_url(@hardware_item, HighLevelRequirement.last)
    STDERR.puts('    The High Level Requirement was created successfully.')
  end

  test "should update high level requirement" do
    STDERR.puts('    Check to see that a High Level Requirement can be updated.')

    patch item_high_level_requirement_url(@hardware_item, @hardware_hlr_001),
      params:
      {
        high_level_requirement:
        {
          reqid:                               @hardware_hlr_001.reqid + 3,
          full_id:                             'HLR-004',
          description:                         @hardware_hlr_001.description,
          category:                            @hardware_hlr_001.category,
          verification_method:                 @hardware_hlr_001.verification_method,
          safety:                              @hardware_hlr_001.safety,
          robustness:                          @hardware_hlr_001.robustness,
          derived:                             @hardware_hlr_001.derived,
          testmethod:                          @hardware_hlr_001.testmethod,
          version:                             @hardware_hlr_001.version,
          item_id:                             @hardware_hlr_001.item_id,
          project_id:                          @hardware_hlr_001.project_id,
          system_requirement_associations:     @hardware_hlr_001.system_requirement_associations,
          derived_justification:               @hardware_hlr_001.derived_justification,
          organization:                        @hardware_hlr_001.organization,
          archive_id:                          @hardware_hlr_001.archive_id,
          high_level_requirement_associations: @hardware_hlr_001.high_level_requirement_associations,
          soft_delete:                         @hardware_hlr_001.soft_delete,
          document_id:                         @hardware_hlr_001.document_id,
          model_file_id:                       @hardware_hlr_001.model_file_id
        }
      }

    assert_redirected_to item_high_level_requirement_url(@hardware_item, @hardware_hlr_001, previous_mode: 'editing')
    STDERR.puts('    The High Level Requirement was successfully updated.')
  end

  test "should destroy high level requirement" do
    STDERR.puts('    Check to see that a High Level Requirement can be deleted.')

    assert_difference('HighLevelRequirement.count', -1) do
      delete item_high_level_requirement_url(@hardware_item, @hardware_hlr_001)
    end

    assert_redirected_to item_high_level_requirements_url(@hardware_item)
    STDERR.puts('    The High Level Requirement was successfully deleted.')
  end

  test "should export high level requirements" do
    STDERR.puts('    Check to see that a High Level Requirement can be exported.')
    get item_high_level_requirements_export_url(@hardware_item)
    assert_response :success

    post item_high_level_requirements_export_url(@hardware_item),
      params:
      {
        hlr_export:
        {
          export_type: 'CSV'
        }
      }

    assert_redirected_to item_high_level_requirements_export_url(@hardware_item, :format => :csv)
    get item_high_level_requirements_export_url(@hardware_item, :format => :csv)
    assert_response :success

    lines = response.body.split("\n")

    assert_equals('id,reqid,full_id,description,category,safety,robustness,derived,testmethod,version,item_id,project_id,system_requirement_associations,derived_justification,created_at,updated_at,organization,verification_method,archive_id,high_level_requirement_associations,soft_delete,document_id,model_file_id,archive_revision,archive_version',
                  lines[0], 'Header',
                  "    Expect Header to be 'id,reqid,full_id,description,category,safety,robustness,derived,testmethod,version,item_id,project_id,system_requirement_associations,derived_justification,created_at,updated_at,organization,verification_method,archive_id,high_level_requirement_associations,soft_delete,document_id,model_file_id,archive_revision,archive_version'. It was...")

    get item_high_level_requirements_export_url(@hardware_item)
    assert_response :success

    post item_high_level_requirements_export_url(@hardware_item),
      params:
      {
        hlr_export:
        {
          export_type: 'PDF'
        }
      }

    assert_redirected_to item_high_level_requirements_export_url(@hardware_item, :format => :pdf)
    get item_high_level_requirements_export_url(@hardware_item, :format => :pdf)
    assert_response :success
    assert_between(18000, 24000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 18000 and 24000.")
    get item_high_level_requirements_export_url(@hardware_item)
    assert_response :success

    post item_high_level_requirements_export_url(@hardware_item),
      params:
      {
        hlr_export:
        {
          export_type: 'XLS'
        }
      }

    assert_redirected_to item_high_level_requirements_export_url(@hardware_item, :format => :xls)
    get item_high_level_requirements_export_url(@hardware_item, :format => :xls)
    assert_response :success
    assert_equals(true, ((response.body.length > 5000) && (response.body.length < 6000)), 'XLS Download Length', "    Expect XLS download length to be > 5000. It was...")
    get item_high_level_requirements_export_url(@hardware_item)
    assert_response :success

    post item_high_level_requirements_export_url(@hardware_item),
      params:
      {
        hlr_export:
        {
          export_type: 'HTML'
        }
      }

    assert_response :success
    STDERR.puts('    A High Level Requirement was exported.')
  end

  test "should import high level requirements" do
    STDERR.puts('    Check to see that a High Level Requirement file can be imported.')
    get item_high_level_requirements_import_url(@hardware_item)
    assert_response :success

    post item_high_level_requirements_import_url(@hardware_item),
      params:
      {
        '/import' =>
        {
          item_select:                   @hardware_item.id,
          duplicates_permitted:          '1',
          association_changes_permitted: '1',
          file:                          fixture_file_upload('files/Hardware Item-High_Level_Requirements.csv')
        }
      }

    assert_redirected_to item_high_level_requirements_url(@hardware_item)
    STDERR.puts('    A High Level Requirement file was imported.')
  end

  test "should renumber" do
    STDERR.puts('    Check to see that the High Level Requirements can be renumbered.')
    get item_high_level_requirements_renumber_url(@hardware_item)
    assert_redirected_to item_high_level_requirements_url(@hardware_item)
    STDERR.puts('    The High Level Requirements were successful renumbered.')
  end

  test "should mark as deleted" do
    STDERR.puts('    Check to see that the High Level Requirements can be marked as deleted.')
    get item_high_level_requirement_mark_as_deleted_url(@hardware_item, @hardware_hlr_001)
    assert_redirected_to item_high_level_requirements_url(@hardware_item)
    STDERR.puts('    The High Level Requirements was successfully marked as deleted.')
  end
end

require 'test_helper'

class ModelFilesControllerTest < ActionDispatch::IntegrationTest
  def unlink_model_file(id)
    system_requirements     = SystemRequirement.where(model_file_id: id)
    high_level_requirements = HighLevelRequirement.where(model_file_id: id)
    low_level_requirements  = LowLevelRequirement.where(model_file_id: id)
    test_cases              = TestCase.where(model_file_id: id)

    system_requirements.each     {|sysreq| sysreq.destroy} if system_requirements.present?
    high_level_requirements.each {|hlr|    hlr.destroy}    if high_level_requirements.present?
    low_level_requirements.each  {|llr|    llr.destroy}    if low_level_requirements.present?
    test_cases.each              {|tc|     tc.destroy}     if test_cases.present?
  end

  def setup
    @project                = Project.find_by(identifier: 'TEST')
    @hardware_item          = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item          = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @model_file_001         = ModelFile.find_by(full_id: 'MF-001')
    @model_file_002         = ModelFile.find_by(full_id: 'MF-002')
    @file_data              = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                           'image/png',
                                                           true)
    @model_file_001.item_id = nil

    @model_file_001.save!
    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Model Files List Page can be loaded.')
    get project_model_files_url(@project)
    assert_response :success
    get item_model_files_url(@hardware_item)
    assert_response :success
    STDERR.puts('    The Model Files List Page loaded successfully.')
  end

  test "should show model_file" do
    STDERR.puts('    Check to see that the Model Files Show Page can be loaded.')
    get project_model_file_url(@project, @model_file_001)
    assert_response :success
    get item_model_file_url(@hardware_item, @model_file_002)
    assert_response :success
    STDERR.puts('    The Model Files Show Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the Model Files New Page can be loaded.')
    get new_item_model_file_url(@hardware_item)
    assert_response :success
    get new_project_model_file_url(@project)
    assert_response :success
    STDERR.puts('    The Model Files New Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the Model Files New Page can be loaded.')
    get edit_project_model_file_path(@project, @model_file_001)
    assert_response :success
    get edit_item_model_file_path(@hardware_item, @model_file_002)
    assert_response :success
    STDERR.puts('    The Model Files New Page loaded successfully.')
  end

  test "should create model_file" do
    STDERR.puts('    Check to see that a Model File can be created.')

    assert_difference('ModelFile.count') do
      post project_model_files_url(@project),
        params:
          {
             model_file:
               {
                  model_id:                            3,
                  full_id:                             'MF-003',
                  description:                         @model_file_001.description,
                  file_path:                           @model_file_001.file_path,
                  file_type:                           @model_file_001.file_type,
                  url_type:                            @model_file_001.url_type,
                  url_description:                     @model_file_001.url_description,
                  url_link:                            @model_file_001.url_link,
                  soft_delete:                         @model_file_001.soft_delete,
                  derived:                             @model_file_001.derived,
                  derived_justification:               @model_file_001.derived_justification,
                  system_requirement_associations:     @model_file_001.system_requirement_associations,
                  high_level_requirement_associations: @model_file_001.high_level_requirement_associations,
                  low_level_requirement_associations:  @model_file_001.low_level_requirement_associations,
                  test_case_associations:              @model_file_001.test_case_associations,
                  version:                             @model_file_001.version,
                  revision:                            @model_file_001.revision,
                  draft_version:                       @model_file_001.draft_version,
                  revision_date:                       @model_file_001.revision_date,
                  organization:                        @model_file_001.organization,
                  project_id:                          @model_file_001.project_id,
                  item_id:                             nil,
                  archive_id:                          @model_file_001.archive_id,
                  upload_date:                         @model_file_001.upload_date
                }
          }

      assert_redirected_to project_model_file_url(@project, ModelFile.last)
    end

    assert_difference('ModelFile.count') do
      post item_model_files_url(@hardware_item),
        params:
          {
             model_file:
               {
                  model_id:                            4,
                  full_id:                             'MF-004',
                  description:                         @model_file_002.description,
                  file_path:                           @model_file_002.file_path,
                  file_type:                           @model_file_002.file_type,
                  url_type:                            @model_file_002.url_type,
                  url_description:                     @model_file_002.url_description,
                  url_link:                            @model_file_002.url_link,
                  soft_delete:                         @model_file_002.soft_delete,
                  derived:                             @model_file_002.derived,
                  derived_justification:               @model_file_002.derived_justification,
                  system_requirement_associations:     @model_file_002.system_requirement_associations,
                  high_level_requirement_associations: @model_file_002.high_level_requirement_associations,
                  low_level_requirement_associations:  @model_file_002.low_level_requirement_associations,
                  test_case_associations:              @model_file_002.test_case_associations,
                  version:                             @model_file_002.version,
                  revision:                            @model_file_002.revision,
                  draft_version:                       @model_file_002.draft_version,
                  revision_date:                       @model_file_002.revision_date,
                  organization:                        @model_file_002.organization,
                  project_id:                          @model_file_002.project_id,
                  item_id:                             @hardware_item.id,
                  archive_id:                          @model_file_002.archive_id,
                  upload_date:                         @model_file_002.upload_date
                }
          }

      assert_redirected_to item_model_file_url(@hardware_item, ModelFile.last)
    end

    STDERR.puts('    The Model File was created successfully.')
  end

  test "should update model_file" do
    STDERR.puts('    Check to see that a Model File can be updated.')

    patch project_model_file_url(@project, @model_file_001),
      params:
              {
                 model_file:
                              {
                                model_id:                            3,
                                full_id:                             'MF-003',
                                description:                         @model_file_001.description,
                                file_path:                           @model_file_001.file_path,
                                file_type:                           @model_file_001.file_type,
                                url_type:                            @model_file_001.url_type,
                                url_description:                     @model_file_001.url_description,
                                url_link:                            @model_file_001.url_link,
                                soft_delete:                         @model_file_001.soft_delete,
                                derived:                             @model_file_001.derived,
                                derived_justification:               @model_file_001.derived_justification,
                                system_requirement_associations:     @model_file_001.system_requirement_associations,
                                high_level_requirement_associations: @model_file_001.high_level_requirement_associations,
                                low_level_requirement_associations:  @model_file_001.low_level_requirement_associations,
                                test_case_associations:              @model_file_001.test_case_associations,
                                version:                             @model_file_001.version,
                                revision:                            @model_file_001.revision,
                                draft_version:                       @model_file_001.draft_version,
                                revision_date:                       @model_file_001.revision_date,
                                organization:                        @model_file_001.organization,
                                project_id:                          @model_file_001.project_id,
                                item_id:                             nil,
                                archive_id:                          @model_file_001.archive_id,
                                upload_date:                         @model_file_001.upload_date
                              }
              }

    assert_redirected_to project_model_file_url(@project, @model_file_001,
                                                previous_mode: 'editing')

    patch item_model_file_url(@hardware_item, @model_file_002),
      params:
              {
                 model_file:
                              {
                                model_id:                            4,
                                full_id:                             'MF-004',
                                description:                         @model_file_002.description,
                                file_path:                           @model_file_002.file_path,
                                file_type:                           @model_file_002.file_type,
                                url_type:                            @model_file_002.url_type,
                                url_description:                     @model_file_002.url_description,
                                url_link:                            @model_file_002.url_link,
                                soft_delete:                         @model_file_002.soft_delete,
                                derived:                             @model_file_002.derived,
                                derived_justification:               @model_file_002.derived_justification,
                                system_requirement_associations:     @model_file_002.system_requirement_associations,
                                high_level_requirement_associations: @model_file_002.high_level_requirement_associations,
                                low_level_requirement_associations:  @model_file_002.low_level_requirement_associations,
                                test_case_associations:              @model_file_002.test_case_associations,
                                version:                             @model_file_002.version,
                                revision:                            @model_file_002.revision,
                                draft_version:                       @model_file_002.draft_version,
                                revision_date:                       @model_file_002.revision_date,
                                organization:                        @model_file_002.organization,
                                project_id:                          @model_file_002.project_id,
                                item_id:                             @hardware_item.id,
                                archive_id:                          @model_file_002.archive_id,
                                upload_date:                         @model_file_002.upload_date
                              }
              }

    assert_redirected_to item_model_file_url(@hardware_item, @model_file_002,
                                             previous_mode: 'editing')
    STDERR.puts('    The Model File was updated successfully.')
  end

  test "should destroy model_file" do
    STDERR.puts('    Check to see that a Model File can be deleted.')
    unlink_model_file(@model_file_001)

    assert_difference('ModelFile.count', -1) do
      delete project_model_file_url(@project, @model_file_001)
    end

    assert_redirected_to project_model_files_url(@project)
    unlink_model_file(@model_file_002)

    assert_difference('ModelFile.count', -1) do
      delete item_model_file_url(@hardware_item, @model_file_002)
    end

    assert_redirected_to item_model_files_url(@hardware_item)
    STDERR.puts('    The Model File was successfully deleted.')
  end

  test "should export model files" do
    STDERR.puts('    Check to see that a Model File can be exported.')

    get project_model_files_export_url(@project)
    assert_response :success

    post project_model_files_export_url(@project),
      params:
      {
        mf_export:
        {
          export_type: 'CSV'
        }
      }

    assert_redirected_to project_model_files_export_url(@project, :format => :csv)
    get project_model_files_export_url(@project, :format => :csv)
    assert_response :success

    lines = response.body.split("\n")

    assert_equals('id,model_id,full_id,description,file_path,file_type,url_type,url_link,url_description,soft_delete,derived,derived_justification,system_requirement_associations,high_level_requirement_associations,low_level_requirement_associations,test_case_associations,version,revision,draft_version,revision_date,organization,project_id,item_id,archive_id,created_at,updated_at,upload_date',
                  lines[0], 'Header',
                  '    Expect header to be id,model_id,full_id,description,file_path,file_type,url_type,url_link,url_description,soft_delete,derived,derived_justification,system_requirement_associations,high_level_requirement_associations,low_level_requirement_associations,test_case_associations,version,revision,draft_version,revision_date,organization,project_id,item_id,archive_id,created_at,updated_at,upload_date. It was.')

    get project_model_files_export_url(@project)
    assert_response :success

    post project_model_files_export_url(@project),
      params:
      {
        mf_export:
        {
          export_type: 'PDF'
        }
      }

    assert_redirected_to project_model_files_export_url(@project, :format => :pdf)
    get project_model_files_export_url(@project, :format => :pdf)
    assert_response :success
    assert_between(15000, 22000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 15000 and 22000.")
    get project_model_files_export_url(@project)
    assert_response :success

    post project_model_files_export_url(@project),
      params:
      {
        mf_export:
        {
          export_type: 'XLS'
        }
      }

    assert_redirected_to project_model_files_export_url(@project, :format => :xls)
    get project_model_files_export_url(@project, :format => :xls)
    assert_response :success
    assert_equals(true, ((response.body.length > 5000) && (response.body.length < 6000)), 'XLS Download Length', "    Expect XLS download length to be > 5000. It was...")
    get project_model_files_export_url(@project)
    assert_response :success

    post project_model_files_export_url(@project),
      params:
      {
        mf_export:
        {
          export_type: 'HTML'
        }
      }

    assert_response :success
    get item_model_files_export_url(@hardware_item)
    assert_response :success

    post item_model_files_export_url(@hardware_item),
      params:
      {
        mf_export:
        {
          export_type: 'CSV'
        }
      }

    assert_redirected_to item_model_files_export_url(@hardware_item, :format => :csv)
    get item_model_files_export_url(@hardware_item, :format => :csv)
    assert_response :success

    lines = response.body.split("\n")

    assert_equals('id,model_id,full_id,description,file_path,file_type,url_type,url_link,url_description,soft_delete,derived,derived_justification,system_requirement_associations,high_level_requirement_associations,low_level_requirement_associations,test_case_associations,version,revision,draft_version,revision_date,organization,project_id,item_id,archive_id,created_at,updated_at,upload_date',
                  lines[0], 'Header',
                  '    Expect header to be id,model_id,full_id,description,file_path,file_type,url_type,url_link,url_description,soft_delete,derived,derived_justification,system_requirement_associations,high_level_requirement_associations,low_level_requirement_associations,test_case_associations,version,revision,draft_version,revision_date,organization,project_id,item_id,archive_id,created_at,updated_at,upload_date. It was.')

    get item_model_files_export_url(@hardware_item)
    assert_response :success

    post item_model_files_export_url(@hardware_item),
      params:
      {
        mf_export:
        {
          export_type: 'PDF'
        }
      }

    assert_redirected_to item_model_files_export_url(@hardware_item, :format => :pdf)
    get item_model_files_export_url(@hardware_item, :format => :pdf)
    assert_response :success
    assert_between(15000, 22000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 15000 and 22000.")
    get item_model_files_export_url(@hardware_item)
    assert_response :success

    post item_model_files_export_url(@hardware_item),
      params:
      {
        mf_export:
        {
          export_type: 'XLS'
        }
      }

    assert_redirected_to item_model_files_export_url(@hardware_item, :format => :xls)
    get item_model_files_export_url(@hardware_item, :format => :xls)
    assert_response :success
    assert_equals(true, ((response.body.length > 5000) && (response.body.length < 6000)), 'XLS Download Length', "    Expect XLS download length to be > 5000. It was...")
    get item_model_files_export_url(@hardware_item)
    assert_response :success

    post item_model_files_export_url(@hardware_item),
      params:
      {
        mf_export:
        {
          export_type: 'HTML'
        }
      }

    assert_response :success
    STDERR.puts('    A Model File was exported.')
  end

  test "should import model files" do
    STDERR.puts('    Check to see that a Model File file can be imported.')

    get project_model_files_import_url(@project)
    assert_response :success

    post project_model_files_import_url(@project),
      params:
      {
        '/import' =>
        {
          project_select:                   @project.id,
          duplicates_permitted:          '1',
          association_changes_permitted: '1',
          file:                          fixture_file_upload('files/Test-Model_Files.csv')
        }
      }

    assert_redirected_to project_model_files_import_url(@project)
    get item_model_files_import_url(@hardware_item)
    assert_response :success

    post item_model_files_import_url(@hardware_item),
      params:
      {
        '/import' =>
        {
          item_select:                   @hardware_item.id,
          duplicates_permitted:          '1',
          association_changes_permitted: '1',
          file:                          fixture_file_upload('files/Hardware Item-Model_Files.csv')
        }
      }

    assert_redirected_to item_model_files_url(@hardware_item)
    STDERR.puts('    A Model File file was imported.')
  end

  test "should renumber" do
    STDERR.puts('    Check to see that the Model Files can be renumbered.')
    get project_model_files_renumber_url(@project)
    assert_redirected_to project_model_files_url(@project)
    get item_model_files_renumber_url(@hardware_item)
    assert_redirected_to item_model_files_url(@hardware_item)
    STDERR.puts('    The Model Files were successful renumbered.')
  end

  test "should mark as deleted" do
    STDERR.puts('    Check to see that the Model Files can be marked as deleted.')
    get project_model_file_mark_as_deleted_url(@project, @model_file_001)
    assert_redirected_to project_model_files_url(@project)
    get item_model_file_mark_as_deleted_url(@hardware_item, @model_file_002)
    assert_redirected_to item_model_files_url(@hardware_item)
    STDERR.puts('    The Model Files was successfully marked as deleted.')
  end
end

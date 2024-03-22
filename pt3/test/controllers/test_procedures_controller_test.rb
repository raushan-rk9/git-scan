require 'test_helper'

class TestProceduresControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project         = Project.find_by(identifier: 'TEST')
    @hardware_item   = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item   = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_tp_001 = TestProcedure.find_by(item_id: @hardware_item.id,
                                             full_id: 'TP-001')
    @hardware_tp_002 = TestProcedure.find_by(item_id: @hardware_item.id,
                                             full_id: 'TP-002')
    @software_tp_001 = TestProcedure.find_by(item_id: @software_item.id,
                                             full_id: 'TP-001')
    @software_tp_002 = TestProcedure.find_by(item_id: @software_item.id,
                                             full_id: 'TP-002')
    @model_file      = ModelFile.find_by(full_id: 'MF-001')
    @file_data       = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                    'image/png',
                                                    true)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Test Procedures List Page can be loaded.')
    get item_test_procedures_url(@hardware_item)
    assert_response :success
    STDERR.puts('    The Test Procedures List Page loaded successfully.')
  end

  test "should show test procedure" do
    STDERR.puts('    Check to see that a Test Procedure can be viewed.')
    get item_test_procedure_url(@hardware_item, @hardware_tp_001)
    assert_response :success
    STDERR.puts('    The Test Procedure view loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Test Procedures Page can be loaded.')
    get new_item_test_procedure_url(@hardware_item)
    assert_response :success
    STDERR.puts('    A new Test Procedures Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit Test Procedure Page can be loaded.')
    get edit_item_test_procedure_url(@hardware_item, @hardware_tp_001)
    assert_response :success
    STDERR.puts('    The Edit Test Procedure page loaded successfully.')
  end

  test "should create test procedure" do
    STDERR.puts('    Check to see that a Test Procedure can be created.')

    assert_difference('TestProcedure.count') do
      post item_test_procedures_url(@hardware_item),
        params:
        {
          test_procedure:
          {
             procedure_id:           @hardware_tp_001.procedure_id + 2,
             full_id:                'TP-003',
             file_name:              @hardware_tp_001.file_name,
             url_type:               @hardware_tp_001.url_type,
             url_description:        @hardware_tp_001.url_description,
             url_link:               @hardware_tp_001.url_link,
             version:                @hardware_tp_001.version,
             organization:           @hardware_tp_001.organization,
             item_id:                @hardware_tp_001.item_id,
             project_id:             @hardware_tp_001.project_id,
             archive_id:             @hardware_tp_001.archive_id,
             test_case_associations: @hardware_tp_001.test_case_associations,
             description:            @hardware_tp_001.description,
             soft_delete:            @hardware_tp_001.soft_delete,
             document_id:            @hardware_tp_001.document_id,
             file_path:              @hardware_tp_001.file_path,
             content_type:           @hardware_tp_001.content_type,
             file_type:              @hardware_tp_001.file_type,
             revision:               @hardware_tp_001.revision,
             draft_version:          @hardware_tp_001.draft_version,
             revision_date:          @hardware_tp_001.revision_date,
             upload_date:            @hardware_tp_001.upload_date
          }
        }
    end

    assert_redirected_to item_test_procedure_url(@hardware_item, TestProcedure.last)
    STDERR.puts('    The Test Procedure was created successfully.')
  end

  test "should update test procedure" do
    STDERR.puts('    Check to see that a Test Procedure can be updated.')

    patch item_test_procedure_url(@hardware_item, @hardware_tp_001),
      params:
      {
        test_procedure:
        {
             procedure_id:             @hardware_tp_001.procedure_id + 2,
             full_id:                'Tp-003',
             file_name:              @hardware_tp_001.file_name,
             url_type:               @hardware_tp_001.url_type,
             url_description:        @hardware_tp_001.url_description,
             url_link:               @hardware_tp_001.url_link,
             version:                @hardware_tp_001.version,
             organization:           @hardware_tp_001.organization,
             item_id:                @hardware_tp_001.item_id,
             project_id:             @hardware_tp_001.project_id,
             archive_id:             @hardware_tp_001.archive_id,
             test_case_associations: @hardware_tp_001.test_case_associations,
             description:            @hardware_tp_001.description,
             soft_delete:            @hardware_tp_001.soft_delete,
             document_id:            @hardware_tp_001.document_id,
             file_path:              @hardware_tp_001.file_path,
             content_type:           @hardware_tp_001.content_type,
             file_type:              @hardware_tp_001.file_type,
             revision:               @hardware_tp_001.revision,
             draft_version:          @hardware_tp_001.draft_version,
             revision_date:          @hardware_tp_001.revision_date,
             upload_date:            @hardware_tp_001.upload_date
        }
      }

    assert_redirected_to item_test_procedure_url(@hardware_item, @hardware_tp_001, previous_mode: 'editing')
    STDERR.puts('    The Test Procedure was successfully updated.')
  end

  test "should destroy test procedure" do
    STDERR.puts('    Check to see that a Test Procedure can be deleted.')

    assert_difference('TestProcedure.count', -1) do
      delete item_test_procedure_url(@hardware_item, @hardware_tp_001)
    end

    assert_redirected_to item_test_procedures_url(@hardware_item)
    STDERR.puts('    The Test Procedure was successfully deleted.')
  end

  test "should export test procedures" do
    STDERR.puts('    Check to see that a Test Procedure can be exported.')
    get item_test_procedures_export_url(@hardware_item)
    assert_response :success

    post item_test_procedures_export_url(@hardware_item),
      params:
      {
        tp_export:
        {
          export_type: 'CSV'
        }
      }

    assert_redirected_to item_test_procedures_export_url(@hardware_item, :format => :csv)
    get item_test_procedures_export_url(@hardware_item, :format => :csv)
    assert_response :success

    lines = response.body.split("\n")

    assert_equals('id,procedure_id,full_id,file_name,url_type,url_description,url_link,version,organization,item_id,project_id,created_at,updated_at,archive_id,test_case_associations,description,soft_delete,document_id,file_path,content_type,file_type,revision,draft_version,revision_date,upload_date,archive_revision,archive_version',
                  lines[0], 'Header',
                  '    Expect header to be "id,procedure_id,full_id,file_name,url_type,url_description,url_link,version,organization,item_id,project_id,created_at,updated_at,archive_id,test_case_associations,description,soft_delete,document_id,file_path,content_type,file_type,revision,draft_version,revision_date,upload_date,archive_revision,archive_version". It was.')

    get item_test_procedures_export_url(@hardware_item)
    assert_response :success

    post item_test_procedures_export_url(@hardware_item),
      params:
      {
        tp_export:
        {
          export_type: 'PDF'
        }
      }

    assert_redirected_to item_test_procedures_export_url(@hardware_item, :format => :pdf)
    get item_test_procedures_export_url(@hardware_item, :format => :pdf)
    assert_response :success
    assert_between(13000, 18000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 13000 and 18000.")
    get item_test_procedures_export_url(@hardware_item)
    assert_response :success

    post item_test_procedures_export_url(@hardware_item),
      params:
      {
        tp_export:
        {
          export_type: 'XLS'
        }
      }

    assert_redirected_to item_test_procedures_export_url(@hardware_item, :format => :xls)
    get item_test_procedures_export_url(@hardware_item, :format => :xls)
    assert_response :success
    assert_equals(true, ((response.body.length > 5000) && (response.body.length < 6000)), 'XLS Download Length', "    Expect XLS download length to be > 5000. It was...")
    get item_test_procedures_export_url(@hardware_item)
    assert_response :success

    post item_test_procedures_export_url(@hardware_item),
      params:
      {
        tp_export:
        {
          export_type: 'HTML'
        }
      }

    assert_response :success
    STDERR.puts('    A Test Procedure was exported.')
  end

  test "should import test procedures" do
    STDERR.puts('    Check to see that a Test Procedure file can be imported.')
    get item_test_procedures_import_url(@hardware_item)
    assert_response :success

    post item_test_procedures_import_url(@hardware_item),
      params:
      {
        '/import' =>
        {
          item_select:                   @hardware_item.id,
          duplicates_permitted:          '1',
          association_changes_permitted: '1',
          file:                          fixture_file_upload('files/Hardware Item-Test_Procedures.csv')
        }
      }

    assert_redirected_to item_test_procedures_url(@hardware_item)
    STDERR.puts('    A Test Procedure file was imported.')
  end

  test "should renumber" do
    STDERR.puts('    Check to see that the Test Procedures can be renumbered.')
    get item_test_procedures_renumber_url(@hardware_item)
    assert_redirected_to item_test_procedures_url(@hardware_item)
    STDERR.puts('    The Test Procedures were successful renumbered.')
  end

  test "should mark as deleted" do
    STDERR.puts('    Check to see that the Test Procedures can be marked as deleted.')
    get item_test_procedure_mark_as_deleted_url(@hardware_item, @hardware_tp_001)
    assert_redirected_to item_test_procedures_url(@hardware_item)
    STDERR.puts('    The Test Procedures was successfully marked as deleted.')
  end
end

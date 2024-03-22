require 'test_helper'

class TestCasesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project         = Project.find_by(identifier: 'TEST')
    @hardware_item   = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item   = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_tc_001 = TestCase.find_by(item_id: @hardware_item.id,
                                        full_id: 'TC-001')
    @hardware_tc_002 = TestCase.find_by(item_id: @hardware_item.id,
                                        full_id: 'TC-002')
    @software_tc_001 = TestCase.find_by(item_id: @software_item.id,
                                        full_id: 'TC-001')
    @software_tc_002 = TestCase.find_by(item_id: @software_item.id,
                                        full_id: 'TC-002')
    @model_file      = ModelFile.find_by(full_id: 'MF-001')
    @file_data       = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                    'image/png',
                                                    true)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Test Cases List Page can be loaded.')
    get item_test_cases_url(@hardware_item)
    assert_response :success
    STDERR.puts('    The Test Cases List Page loaded successfully.')
  end

  test "should show test case" do
    STDERR.puts('    Check to see that a Test Case can be viewed.')
    get item_test_case_url(@hardware_item, @hardware_tc_001)
    assert_response :success
    STDERR.puts('    The Test Case view loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Test Cases Page can be loaded.')
    get new_item_test_case_url(@hardware_item)
    assert_response :success
    STDERR.puts('    A new Test Cases Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit Test Case Page can be loaded.')
    get edit_item_test_case_url(@hardware_item, @hardware_tc_001)
    assert_response :success
    STDERR.puts('    The Edit Test Case page loaded successfully.')
  end

  test "should create test case" do
    STDERR.puts('    Check to see that a Test Case can be created.')

    assert_difference('TestCase.count') do
      post item_test_cases_url(@hardware_item),
        params:
        {
          test_case:
          {
             caseid:                              @hardware_tc_001.caseid + 3,
             full_id:                             'TC-004',
             description:                         @hardware_tc_001.description,
             procedure:                           @hardware_tc_001.procedure,
             category:                            @hardware_tc_001.category,
             robustness:                          @hardware_tc_001.robustness,
             derived:                             @hardware_tc_001.derived,
             testmethod:                          @hardware_tc_001.testmethod,
             version:                             @hardware_tc_001.version,
             item_id:                             @hardware_tc_001.item_id,
             project_id:                          @hardware_tc_001.project_id,
             high_level_requirement_associations: @hardware_tc_001.high_level_requirement_associations,
             derived_justification:               @hardware_tc_001.derived_justification,
             organization:                        @hardware_tc_001.organization,
             archive_id:                          @hardware_tc_001.archive_id,
             low_level_requirement_associations:  @hardware_tc_001.low_level_requirement_associations,
             soft_delete:                         @hardware_tc_001.soft_delete,
             document_id:                         @hardware_tc_001.document_id,
             model_file_id:                       @hardware_tc_001.model_file_id
          }
        }
    end

    assert_redirected_to item_test_case_url(@hardware_item, TestCase.last)
    STDERR.puts('    The Test Case was created successfully.')
  end

  test "should update test case" do
    STDERR.puts('    Check to see that a Test Case can be updated.')

    patch item_test_case_url(@hardware_item, @hardware_tc_001),
      params:
      {
        test_case:
        {
          caseid:                              @hardware_tc_001.caseid + 3,
          full_id:                             'TC-004',
          description:                         @hardware_tc_001.description,
          procedure:                           @hardware_tc_001.procedure,
          category:                            @hardware_tc_001.category,
          robustness:                          @hardware_tc_001.robustness,
          derived:                             @hardware_tc_001.derived,
          testmethod:                          @hardware_tc_001.testmethod,
          version:                             @hardware_tc_001.version,
          item_id:                             @hardware_tc_001.item_id,
          project_id:                          @hardware_tc_001.project_id,
          high_level_requirement_associations: @hardware_tc_001.high_level_requirement_associations,
          derived_justification:               @hardware_tc_001.derived_justification,
          organization:                        @hardware_tc_001.organization,
          archive_id:                          @hardware_tc_001.archive_id,
          low_level_requirement_associations:  @hardware_tc_001.low_level_requirement_associations,
          soft_delete:                         @hardware_tc_001.soft_delete,
          document_id:                         @hardware_tc_001.document_id,
          model_file_id:                       @hardware_tc_001.model_file_id
        }
      }

    assert_redirected_to item_test_case_url(@hardware_item, @hardware_tc_001, previous_mode: 'editing')
    STDERR.puts('    The Test Case was successfully updated.')
  end

  test "should destroy test case" do
    STDERR.puts('    Check to see that a Test Case can be deleted.')

    assert_difference('TestCase.count', -1) do
      delete item_test_case_url(@hardware_item, @hardware_tc_001)
    end

    assert_redirected_to item_test_cases_url(@hardware_item)
    STDERR.puts('    The Test Case was successfully deleted.')
  end

  test "should export test cases" do
    STDERR.puts('    Check to see that a Test Case can be exported.')
    get item_test_cases_export_url(@hardware_item)
    assert_response :success

    post item_test_cases_export_url(@hardware_item),
      params:
      {
        tc_export:
        {
          export_type: 'CSV'
        }
      }

    assert_redirected_to item_test_cases_export_url(@hardware_item, :format => :csv)
    get item_test_cases_export_url(@hardware_item, :format => :csv)
    assert_response :success

    lines = response.body.split("\n")

    assert_equals('id,caseid,full_id,description,procedure,category,robustness,derived,derived_justification,testmethod,version,item_id,project_id,high_level_requirement_associations,low_level_requirement_associations,created_at,updated_at,organization,archive_id,soft_delete,document_id,model_file_id,archive_revision,archive_version',
                  lines[0], 'Header',
                  '    Expect header to be "id,caseid,full_id,description,procedure,category,robustness,derived,derived_justification,testmethod,version,item_id,project_id,high_level_requirement_associations,low_level_requirement_associations,created_at,updated_at,organization,archive_id,soft_delete,document_id,model_file_id,archive_revision,archive_version". It was.')

    get item_test_cases_export_url(@hardware_item)
    assert_response :success

    post item_test_cases_export_url(@hardware_item),
      params:
      {
        tc_export:
        {
          export_type: 'PDF'
        }
      }

    assert_redirected_to item_test_cases_export_url(@hardware_item, :format => :pdf)
    get item_test_cases_export_url(@hardware_item, :format => :pdf)
    assert_response :success
    assert_between(17000, 22000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 17000 and 22000.")
    get item_test_cases_export_url(@hardware_item)
    assert_response :success

    post item_test_cases_export_url(@hardware_item),
      params:
      {
        tc_export:
        {
          export_type: 'XLS'
        }
      }

    assert_redirected_to item_test_cases_export_url(@hardware_item, :format => :xls)
    get item_test_cases_export_url(@hardware_item, :format => :xls)
    assert_response :success
    assert_equals(true, ((response.body.length > 5000) && (response.body.length < 6000)), 'XLS Download Length', "    Expect XLS download length to be > 5000. It was...")
    get item_test_cases_export_url(@hardware_item)
    assert_response :success

    post item_test_cases_export_url(@hardware_item),
      params:
      {
        tc_export:
        {
          export_type: 'HTML'
        }
      }

    assert_response :success
    STDERR.puts('    A Test Case was exported.')
  end

  test "should import test cases" do
    STDERR.puts('    Check to see that a Test Case file can be imported.')
    get item_test_cases_import_url(@hardware_item)
    assert_response :success

    post item_test_cases_import_url(@hardware_item),
      params:
      {
        '/import' =>
        {
          item_select:                   @hardware_item.id,
          duplicates_permitted:          '1',
          association_changes_permitted: '1',
          file:                          fixture_file_upload('files/Hardware Item-Test_Cases.csv')
        }
      }

    assert_redirected_to item_test_cases_url(@hardware_item)
    STDERR.puts('    A Test Case file was imported.')
  end

  test "should renumber" do
    STDERR.puts('    Check to see that the Test Cases can be renumbered.')
    get item_test_cases_renumber_url(@hardware_item)
    assert_redirected_to item_test_cases_url(@hardware_item)
    STDERR.puts('    The Test Cases were successful renumbered.')
  end

  test "should mark as deleted" do
    STDERR.puts('    Check to see that the Test Cases can be marked as deleted.')
    get item_test_case_mark_as_deleted_url(@hardware_item, @hardware_tc_001)
    assert_redirected_to item_test_cases_url(@hardware_item)
    STDERR.puts('    The Test Cases was successfully marked as deleted.')
  end
end

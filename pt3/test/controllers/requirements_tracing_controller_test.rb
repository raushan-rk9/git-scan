require 'test_helper'

class RequirementsTracingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project       = Project.find_by(identifier: 'TEST')
    @hardware_item = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Requrements Tracing Matrix Selection Page can be loaded.')
    get item_requirements_tracing_path(@software_item)
    assert_response :success
    STDERR.puts('    The Requrements Tracing Matrix Selection Page loaded successfully.')
  end

  test "should get specific" do
    STDERR.puts('    Check to see that the Requrements Tracing Matrix Page can be loaded.')
    get item_requirements_tracing_specific_path(@software_item,
                                                requirements: "system_requirements,high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures")
    assert_response :success
    STDERR.puts('    The Requrements Tracing Matrix Page loaded successfully.')
  end

  test "should get unlinked" do
    STDERR.puts('    Check to see that the Requrements Tracing Matrix Unlinked Page can be loaded.')
    get item_requirements_tracing_unlinked_path(@software_item,
                                                requirements: "system_requirements,high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures")
    assert_response :success
    STDERR.puts('    The Requrements Tracing Matrix Unlinked Page loaded successfully.')
  end

  test "should get derived" do
    STDERR.puts('    Check to see that the Requrements Tracing Matrix Derived Page can be loaded.')
    get item_requirements_tracing_derived_path(@software_item,
                                               requirements: "system_requirements,high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures")
    assert_response :success
    STDERR.puts('    The Requrements Tracing Matrix Derived Page loaded successfully.')
  end

  test "should get unallocated" do
    STDERR.puts('    Check to see that the Requrements Tracing Matrix Unallocated Page can be loaded.')
    get item_requirements_tracing_unallocated_path(@software_item,
                                                requirements: "system_requirements,high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures")
    assert_response :success
    STDERR.puts('    The Requrements Tracing Matrix Unallocated Page loaded successfully.')
  end

  test "should get system_allocation" do
    STDERR.puts('    Check to see that the System Allocation Page can be loaded.')
    get project_system_requirements_allocation_path(@project)
    assert_response :success
    STDERR.puts('    The System Allocation Page loaded successfully.')
  end

  test "should get system_unallocated" do
    STDERR.puts('    Check to see that the System Unallocated Page can be loaded.')
    get project_system_requirements_unallocated_path(@project)
    assert_response :success
    STDERR.puts('    The System Unallocated Page loaded successfully.')
  end

  test "should export" do
    STDERR.puts('    Check to see that the Requirement Trace Matix can be exported.')
    get item_requirements_tracing_export_url(@hardware_item)
    assert_response :success

    post item_requirements_tracing_export_path(@software_item),
      params:
      {
        rtm_export:
        {
          export_type: 'csv'
        },

        requirements:  'system_requirements,high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures'
      }

    assert_response :success

    lines = response.body.split("\n")

    assert_equals('System Requirements,High-Level Requirements,HARDWARE_ITEM High-Level Requirements,Low-Level Requirements,Source Code,Test Cases,Test Procedures', lines[0], 'Header', "    Expect Header to be 'System Requirements,High-Level Requirements,HARDWARE_ITEM High-Level Requirements,Low-Level Requirements,Source Code,Test Cases,Test Procedures'. It was...")
    get item_requirements_tracing_export_url(@hardware_item)
    assert_response :success

    post item_requirements_tracing_export_path(@software_item),
      params:
      {
        rtm_export:
        {
          export_type: 'pdf'
        },

        requirements:  'system_requirements,high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures'
      }

    assert_response :success
    assert_between(13000, 21000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 13000 and 21000.")
    get item_requirements_tracing_export_url(@hardware_item)
    assert_response :success

    post item_requirements_tracing_export_path(@software_item),
      params:
      {
        rtm_export:
        {
          export_type: 'xls'
        },

        requirements:  'system_requirements,high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures'
      }

    assert_response :success
    assert_equals(true, ((response.body.length > 4000) && (response.body.length < 5000)), 'XLS Download Length', "    Expect XLS download length to be > 5000. It was...")
    get item_requirements_tracing_export_url(@hardware_item)
    assert_response :success

    post item_requirements_tracing_export_path(@software_item),
      params:
      {
        rtm_export:
        {
          export_type: 'HTML'
        },

        requirements:  'system_requirements,high_level_requirements,low_level_requirements,source_code,test_cases,test_procedures'
      }

    assert_response :success
    STDERR.puts('    The Requirement Trace Matix was exported successfully.')
  end
end

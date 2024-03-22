require 'test_helper'

class SystemRequirementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project            = Project.find_by(identifier: 'TEST')
    @system_requirement = SystemRequirement.find_by(full_id: 'SYS-001')
    @model_file         = ModelFile.find_by(full_id: 'MF-001')
    @file_data          = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                       'image/png',
                                                       true)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the System Requirements List Page can be loaded.')
    get project_system_requirements_url(@project)
    assert_response :success
    STDERR.puts('    The System Requirements List Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the New System Requirement Page can be loaded.')
    get new_project_system_requirement_url(@project)
    assert_response :success
    STDERR.puts('    The New System Requirements Page loaded successfully.')
  end

  test "should create system requirement" do
    STDERR.puts('    Check to see that a New System Requirement can be created.')
    assert_difference('SystemRequirement.count') do
      post project_system_requirements_url(@project),
        params:
        {
          system_requirement:
          {
            reqid:                 @system_requirement.reqid + 3,
            full_id:               @system_requirement.full_id.sub(/\-001$/, '-004'),
            description:           @system_requirement.description,
            source:                @system_requirement.source,
            safety:                @system_requirement.safety,
            implementation:        @system_requirement.implementation,
            version:               @system_requirement.version,
            project_id:            @system_requirement.project_id,
            organization:          @system_requirement.organization,
            category:              @system_requirement.category,
            verification_method:   @system_requirement.verification_method,
            derived:               @system_requirement.derived,
            derived_justification: @system_requirement.derived_justification,
            archive_id:            @system_requirement.archive_id,
            soft_delete:           @system_requirement.soft_delete,
            document_id:           @system_requirement.document_id,
            model_file_id:         @system_requirement.model_file_id
          }
        }
    end

    assert_redirected_to project_system_requirement_url(@project, SystemRequirement.last)
    STDERR.puts('    A New System Requirements was successfully created.')
  end

  test "should show system requirement" do
    STDERR.puts('    Check to see that the System Requirement can be shown.')
    get project_system_requirement_url(@project, @system_requirement)
    assert_response :success
    STDERR.puts('    The System Requirements was successfully viewed.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the System Requirements Edit Page can be loaded.')
    get edit_project_system_requirement_url(@project, @system_requirement)
    assert_response :success
    STDERR.puts('    The System Requirements Edit Page loaded successfully.')
  end

  test "should update system requirement" do
    STDERR.puts('    Check to see that a New System Requirement can be updated.')
    patch project_system_requirement_url(@project, @system_requirement), params: { system_requirement: { description: @system_requirement.description, implementation: @system_requirement.implementation, reqid: @system_requirement.reqid, safety: @system_requirement.safety, source: @system_requirement.source, project_id: @system_requirement.project_id } }
    assert_redirected_to project_system_requirement_url(@project, @system_requirement, previous_mode: 'editing')
    STDERR.puts('    A New System Requirements was successfully updated.')
  end

  test "should destroy system requirement" do
    STDERR.puts('    Check to see that a New System Requirement can be deleted.')

    assert_difference('SystemRequirement.count', -1) do
      delete project_system_requirement_url(@project, @system_requirement)
    end

    assert_redirected_to project_system_requirements_url(@project)
    STDERR.puts('    A New System Requirements was successfully deleted.')
  end

  test "should export system requirements" do
    STDERR.puts('    Check to see that a System Requirement can be exported.')
    get project_system_requirements_export_url(@project)
    assert_response :success

    post project_system_requirements_export_url(@project),
      params:
      {
        sysreq_export:
        {
          export_type: 'CSV'
        }
      }

    assert_redirected_to project_system_requirements_export_path(@project, :format => :csv)
    get project_system_requirements_export_url(@project, :format => :csv)
    assert_response :success

    lines = response.body.split("\n")

    assert_equals('id,reqid,full_id,description,category,verification_method,source,safety,implementation,version,derived,derived_justification,project_id,created_at,updated_at,organization,archive_id,soft_delete,document_id,model_file_id',
                  lines[0], 'Header',
                  '    Expect header to be "id,reqid,full_id,description,category,verification_method,source,safety,implementation,version,derived,derived_justification,project_id,created_at,updated_at,organization,archive_id,soft_delete,document_id,model_file_id". It was.')

    get project_system_requirements_export_url(@project)
    assert_response :success

    post project_system_requirements_export_url(@project),
      params:
      {
        sysreq_export:
        {
          export_type: 'PDF'
        }
      }

    assert_redirected_to project_system_requirements_export_path(@project, :format => :pdf)
    get project_system_requirements_export_url(@project, :format => :pdf)
    assert_response :success
    assert_between(18000, 24000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 18000 and 24000.")
    get project_system_requirements_export_url(@project)
    assert_response :success

    post project_system_requirements_export_url(@project),
      params:
      {
        sysreq_export:
        {
          export_type: 'XLS'
        }
      }

    assert_redirected_to project_system_requirements_export_path(@project, :format => :xls)
    get project_system_requirements_export_url(@project, :format => :xls)
    assert_response :success
    assert_equals(true, ((response.body.length > 5000) && (response.body.length < 6000)), 'XLS Download Length', "    Expect XLS download length to be > 5000. It was...")
    get project_system_requirements_export_url(@project)
    assert_response :success

    post project_system_requirements_export_url(@project),
      params:
      {
        sysreq_export:
        {
          export_type: 'HTML'
        }
      }

    assert_response :success
    STDERR.puts('    A System Requirement was exported.')
  end

  test "should get import" do
    STDERR.puts('    Check to see that a System Requirement file can be imported.')

    post project_system_requirements_import_url(@project),
      params:
      {
        '/import' =>
        {
          project_select:               @project.id,
          duplicates_permitted:          '1',
          file:                          fixture_file_upload('files/Test-System_Requirements.csv')
        }
      }

    assert_redirected_to project_system_requirements_path(@project)
    STDERR.puts('    A System Requirement file was imported.')
  end

  test "should renumber" do
    STDERR.puts('    Check to see that the System Requirements can be renumbered.')
    get project_system_requirements_renumber_url(@project)
    assert_redirected_to project_system_requirements_url(@project)
    STDERR.puts('    The System Requirements were successful renumbered.')
  end

  test "should mark as deleted" do
    STDERR.puts('    Check to see that the System Requirements can be marked as deleted.')
    get project_system_requirement_mark_as_deleted_url(@project, @system_requirement)
    assert_redirected_to project_system_requirements_url(@project)
    STDERR.puts('    The System Requirements was successfully marked as deleted.')
  end
end

require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project            = Project.find_by(identifier: 'TEST')

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Projects List Page can be loaded.')
    get projects_url
    assert_response :success
    STDERR.puts('    The Projects List Page loaded successfully.')
  end

  test "should show project" do
    STDERR.puts('    Check to see that a Show Project Page can be loaded.')
    get project_url(@project)
    assert_response :success
    STDERR.puts('    The Show Project Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a New Project Page can be loaded.')
    get new_project_url
    assert_response :success
    STDERR.puts('    The New Project Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit Project Page can be loaded.')
    get edit_project_url(@project)
    assert_response :success
    STDERR.puts('    The Edit Project Page loaded successfully.')
  end

  test "should create project" do
    STDERR.puts('    Check to see that a Project can be created.')

    assert_difference('Project.count') do
      post projects_url,
        params:
        {
          project:
          {
              identifier:                     @project.identifier + '_001',
              name:                           @project.name,
              description:                    @project.description,
              access:                         @project.access,
              project_managers:               @project.project_managers,
              configuration_managers:         @project.configuration_managers,
              quality_assurance:              @project.quality_assurance,
              team_members:                   @project.team_members,
              airworthiness_reps:             @project.airworthiness_reps,
              system_requirements_prefix:     @project.system_requirements_prefix,
              high_level_requirements_prefix: @project.high_level_requirements_prefix,
              low_level_requirements_prefix:  @project.low_level_requirements_prefix,
              source_code_prefix:             @project.source_code_prefix,
              test_case_prefix:               @project.test_case_prefix,
              test_procedure_prefix:          @project.test_procedure_prefix,
              model_file_prefix:              @project.model_file_prefix
          }
        }
    end

    assert_redirected_to project_url(Project.last)
    STDERR.puts('    The Project was created successfully.')
  end

  test "should update project" do
    STDERR.puts('    Check to see that a Project can be updated.')
    patch project_url(@project), params: { project: { identifier: @project.identifier, name: @project.name } }
    assert_redirected_to project_url(@project)
    STDERR.puts('    The Project was updated successfully.')
  end

  test "should destroy project" do
    STDERR.puts('    Check to see that a Project can be deleted.')

    assert_difference('Project.count', -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
    STDERR.puts('    The Project was deleted successfully.')
  end
end

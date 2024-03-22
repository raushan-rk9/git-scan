require 'test_helper'

class RequirementsBaselinesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project            = Project.find_by(identifier: 'TEST')
    @hardware_item      = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item      = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @archive            = Archive.find_by(name: 'TEST_001')

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Requirements Baselines List Page can be loaded.')
    get project_requirements_baselines_url(@project)
    assert_response :success
    STDERR.puts('    The Requirements Baselines List page loaded successfully.')
  end

  test "should show requirements_baseline" do
    STDERR.puts('    Check to see that the Requirements Baselines Show Page can be loaded.')
    get project_requirements_baseline_url(@project, @archive)
    assert_response :success
    STDERR.puts('    The Requirements Baselines Show page loaded successfully.')
  end

  test "should get new" do
    get new_requirements_baseline_url
    assert_response :success
  end

  test "should get edit" do
    get edit_requirements_baseline_url(@requirements_baseline)
    assert_response :success
  end

  test "should create requirements_baseline" do
    assert_difference('RequirementsBaseline.count') do
      post requirements_baselines_url, params: { requirements_baseline: { archive_type: @requirements_baseline.archive_type, archived_at: @requirements_baseline.archived_at, description: @requirements_baseline.description, full_id: @requirements_baseline.full_id, name: @requirements_baseline.name, organization: @requirements_baseline.organization, pact_version: @requirements_baseline.pact_version, project_id: @requirements_baseline.project_id, revision: @requirements_baseline.revision, version: @requirements_baseline.version } }
    end

    assert_redirected_to requirements_baseline_url(RequirementsBaseline.last)
  end

  test "should update requirements_baseline" do
    patch requirements_baseline_url(@requirements_baseline), params: { requirements_baseline: { archive_type: @requirements_baseline.archive_type, archived_at: @requirements_baseline.archived_at, description: @requirements_baseline.description, full_id: @requirements_baseline.full_id, name: @requirements_baseline.name, organization: @requirements_baseline.organization, pact_version: @requirements_baseline.pact_version, project_id: @requirements_baseline.project_id, revision: @requirements_baseline.revision, version: @requirements_baseline.version } }
    assert_redirected_to requirements_baseline_url(@requirements_baseline)
  end

  test "should destroy requirements_baseline" do
    assert_difference('RequirementsBaseline.count', -1) do
      delete requirements_baseline_url(@requirements_baseline)
    end

    assert_redirected_to requirements_baselines_url
  end
end

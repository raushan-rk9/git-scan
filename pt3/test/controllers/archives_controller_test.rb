require 'test_helper'

class ArchivesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project            = Project.find_by(identifier: 'TEST')
    @hardware_item      = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item      = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @archive            = Archive.find_by(name: 'TEST_001')
    @archive_project    = Project.new({
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
                                         model_file_prefix:              @project.model_file_prefix,
                                         archive_id:                     @archive.id
                                      })

    @archive_project.save!

    @archive_item       = Item.new({
                                         name:                           @hardware_item.name,
                                         itemtype:                       @hardware_item.itemtype,
                                         identifier:                     @hardware_item.identifier,
                                         level:                          @hardware_item.level,
                                         project_id:                     @archive_project.id,
                                         hlr_count:                      @hardware_item.hlr_count,
                                         llr_count:                      @hardware_item.llr_count,
                                         review_count:                   @hardware_item.review_count,
                                         tc_count:                       @hardware_item.tc_count,
                                         sc_count:                       @hardware_item.sc_count,
                                         organization:                   @hardware_item.organization,
                                         high_level_requirements_prefix: @hardware_item.high_level_requirements_prefix,
                                         low_level_requirements_prefix:  @hardware_item.low_level_requirements_prefix,
                                         source_code_prefix:             @hardware_item.source_code_prefix,
                                         test_case_prefix:               @hardware_item.test_case_prefix,
                                         test_procedure_prefix:          @hardware_item.test_procedure_prefix,
                                         tp_count:                       @hardware_item.tp_count,
                                         model_file_prefix:              @hardware_item.model_file_prefix,
                                         archive_id:                     @archive.id
                                      })

    @archive_item.save!

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Archives List Page can be loaded.')
    get project_archives_url(@project)
    assert_response :success
    STDERR.puts('    The Archives List page loaded successfully.')
  end

  test "should show archive" do
    STDERR.puts('    Check to see that an Archive Show page can be loaded.')
    get project_archive_url(@project, @archive)
    assert_response :success
    STDERR.puts('    The Archives Show page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Archive page can be loaded.')
    get new_project_archive_url(@project)
    assert_response :success
    STDERR.puts('    A new Archive page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a edit Archive page can be loaded.')
    get edit_project_archive_url(@project, @archive)
    assert_response :success
    STDERR.puts('    A edit Archive page loaded successfully.')
  end

  test "should create archive" do
    STDERR.puts('    Check to see that a new Archive can be created.')
    clear_model_files
    assert_difference('Archive.count') do
      post project_archives_url(@project),
        params: 
          {
            archive:
              {
                name:               'TEST_002',
                full_id:            "Test Archive (002) - #{DateTime.now}",
                description:        'Test Project Archive (002)',
                revision:           '',
                version:            1,
                archived_at:        DateTime.now,
                organization:       'TEST',
                project_id:         @project.id,
                pact_version:       '1.7',
                archive_type:       'PROJECT',
                item_id:            @hardware_item.id,
                archive_project_id: @archive_project.id,
                archive_item_id:    @archive_item.id
              }
          }
    end

    assert_redirected_to project_archive_url(@project, Archive.last)
    STDERR.puts('    A new Archive was successfully created.')
  end

  test "should update archive" do
    STDERR.puts('    Check to see that an Archive can be update.')
    patch project_archive_url(@project, @archive),
      params: 
        {
          archive:
            {
              name:               @archive.name,
              full_id:            @archive.full_id,
              description:        @archive.description,
              revision:           'a',
              version:            @archive.version,
              archived_at:        @archive.archived_at,
              organization:       @archive.organization,
              project_id:         @archive.project_id,
              pact_version:       @archive.pact_version,
              archive_type:       @archive.archive_type,
              item_id:            @archive.item_id,
              archive_project_id: @archive.archive_project_id,
              archive_item_id:    @archive.archive_item_id
            }
        }

    assert_redirected_to project_url(@project)
    STDERR.puts('    An Archive was successfully updated.')
  end

  test "should destroy archive" do
    STDERR.puts('    Check to see that an archive can be deleted.')
    assert_difference('Archive.count', -1) do
      delete project_archive_url(@project, @archive)
    end

    assert_redirected_to projects_url
    STDERR.puts('    An Archive was successfully deleted.')
  end
end

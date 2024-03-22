require 'test_helper'

class ArchiveTest < ActiveSupport::TestCase
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

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Archive' do
    STDERR.puts('    Check to see that an Archive can be created.')

    archive = Archive.new({
                             name:               @archive.name,
                             full_id:            @archive.full_id,
                             description:        @archive.description,
                             revision:           @archive.revision,
                             version:            @archive.version,
                             archived_at:        @archive.archived_at,
                             organization:       @archive.organization,
                             project_id:         @archive.project_id,
                             pact_version:       @archive.pact_version,
                             archive_type:       @archive.archive_type,
                             item_id:            @archive.item_id,
                             archive_project_id: @archive.archive_project_id,
                             archive_item_id:    @archive.archive_item_id,
                             archive_item_ids:   @archive.archive_item_ids
                          })

    assert_not_equals_nil(archive.save, 'Archive Record', '    Expect Archive Record to be created. It was.')
    STDERR.puts('    An Archive Item was successfully created.')
  end

  test 'should update Archive' do
    STDERR.puts('    Check to see that an Archive can be updated.')
    @archive.name        = 'TEST_002'
    @archive.full_id     = "Test Archive (002) - #{DateTime.now}"
    @archive.description = 'Test Project Archive (002)'
    @archive.archived_at = DateTime.now
    @archive.version     = 2

    assert_not_equals_nil(@archive.save, 'Archive Record', '    Expect Archive Record to be updated. It was.')
    assert_not_equals_nil(Archive.find_by(name: 'TEST_002'), 'Archive Record',
                          "    Expect Original Archive to be renamed. It was.")
    assert_equals(nil, Archive.find_by(name: 'TEST_001'), 'Archive Record',
                  "    Expect Original Archive not to be found. It was not.")
    STDERR.puts('    An Archive Item was successfully updated.')
  end

  test 'should delete Archive' do
    STDERR.puts('    Check to see that an Archive can be deleted.')
    assert(@archive.delete)
    STDERR.puts('    An Archive Item was successfully deleted.')
  end

  test 'should create Archive with undo/redo' do
    STDERR.puts('    Check to see that an Archive can be created, then undone and then redone.')

    data_change = nil
    archive     = Archive.new({
                                name:               'TEST_002',
                                full_id:            "Test Archive (002) - #{DateTime.now}",
                                description:        'Test Project Archive (002)',
                                revision:           '',
                                version:            2,
                                archived_at:        DateTime.now,
                                organization:       'test',
                                project_id:         @project_id,
                                pact_version:       '1.7',
                                archive_type:       'PROJECT'
                              })

    assert_difference('Archive.count', +1) do
      data_change = DataChange.save_or_destroy_with_undo_session(archive,
                                                                 'create')
    end

    assert_not_equals_nil(data_change, 'Archive Record',
                          '    Expect Archive Record to be created. It was.')

    assert_difference('Archive.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('Archive.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    An Archive was successfully created, then undone and then redone.')
  end

  test 'should update Archive with undo/redo' do
    STDERR.puts('    Check to see that an Archive can be updated, then undone and then redone.')

    @archive.name        = 'TEST_002'
    @archive.full_id     = "Test Archive (002) - #{DateTime.now}"
    @archive.description = 'Test Project Archive (002)'
    @archive.archived_at = DateTime.now
    @archive.version     = 2
    data_change          = DataChange.save_or_destroy_with_undo_session(@archive,
                                                                         'update')

    assert(data_change)
    assert_not_equals_nil(Archive.find_by(name: 'TEST_002'), 'Archive Record',
                          "    Expect Original Archive to be renamed. It was.")
    assert_equals(nil, Archive.find_by(name: 'TEST_001'), 'Archive Record',
                  "    Expect Original Archive not to be found. It was not.")
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil,Archive.find_by(name: 'TEST_002'), 'Archive Record',
                          "    Expect Original Archive to be renamed. It was.")
    assert_not_equals_nil(Archive.find_by(name: 'TEST_001'), 'Archive Record',
                          "    Expect Original Archive not to be found. It was not.")
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(Archive.find_by(name: 'TEST_002'), 'Archive Record',
                          "    Expect Original Archive to be renamed. It was.")
    assert_equals(nil, Archive.find_by(name: 'TEST_001'), 'Archive Record',
                  "    Expect Original Archive not to be found. It was not.")
    STDERR.puts('    An Archive was successfully updated, then undone and then redone.')
  end

  test 'should delete Archive with undo/redo' do
    STDERR.puts('    Check to see that an Archive can be deleted, then undone and then redone.')

    data_change   = nil

    assert_difference('Archive.count', -1) do
      data_change = DataChange.save_or_destroy_with_undo_session(@archive,
                                                                 'delete')
    end

    assert(data_change)

    assert_difference('Archive.count', +1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('Archive.count', -1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    An Archive was successfully deleted, then undone and then redone.')
  end

  test 'full_id_from_id' do
    STDERR.puts('    Check to see that an Archive returns the Full ID from an ID.')

    full_id = Archive.full_id_from_id(@archive.id)

    assert_equals('Test Archive (001)', full_id[0..17], 'Archive Record',
                  "    Expect full_id_from_id to be Test Archive (001). It was.")

    STDERR.puts('    The Archive successfully returned the Full ID from an ID.')
  end

  test 'id_from_full_id' do
    STDERR.puts('    Check to see that an Archive returns the ID from a full ID.')
    assert_equals(@archive.id, Archive.id_from_full_id(@archive.id),
                  'Archive ID',
                  "    Expect id_from_full_id to be #{@archive.id}. It was.")
    assert_equals(@archive.id, Archive.id_from_full_id(@archive.id.to_s),
                  'Archive ID',
                  "    Expect id_from_full_id to be #{@archive.id}. It was.")
    assert_equals(@archive.id, Archive.id_from_full_id(@archive.full_id),
                  'Archive ID',
                  "    Expect id_from_full_id to be #{@archive.id}. It was.")
    STDERR.puts('    The Archive successfully returned the ID from a full ID.')
  end

  test 'name_from_id' do
    STDERR.puts('    Check to see that an Archive returns the Name from an ID.')
    assert_equals('TEST_001', Archive.name_from_id(@archive.id), 'Archive Record',
                  "    Expect full_id_from_id to be Test Archive (001). It was.")
    STDERR.puts('    The Archive successfully returned the Name from an ID.')
  end

  test 'parent_project_id_from_archive_id' do
    STDERR.puts('    Check to see that an Archive returns the Parent Project ID from an Archive ID.')
    assert_equals(@project.id, Archive.parent_project_id_from_archive_id(@archive.id),
                  'Archive Record',
                  "    Expect full_id_from_id to be Test Archive (001). It was.")
    STDERR.puts('    The Archive successfully returned the Parent Project ID  from an Archive ID.')
  end

  test 'project_from_archive_id' do
    # To Do: Create an archive project in fixtures
    STDERR.puts('    Check to see that an Archive returns the Project ID from an Archive ID.')

    assert_not_equals_nil(Archive.project_from_archive_id(@archive.id),
                          'Archive Record',
                          "    Expect full_id_from_id to be Test Archive (001). It was.")
    STDERR.puts('    The Archive successfully returned the Project ID  from an Archive ID.')
  end

  test 'archived' do
    STDERR.puts('    Check to see that an Archive returns archived status correctly.')
    assert(!Archive.archived)
    assert_equals(true, Archive.archived({ project_id: @project.id, archive_types: [ 'PROJECT' ] }),
                  "Archive.archived({ project_id: #{@project.id}, archive_types: [ 'PROJECT' ] })",
                  "    Expect Archive.archived({ project_id: #{@project.id}, archive_types: [ 'PROJECT' ] }) to be true). It was.")
    STDERR.puts('    The Archive successfully returned the correct archived status.')
  end

  test 'generate_key' do
    STDERR.puts('    Check to see that an Archive correctly generates a key.')
    assert_equals('high_level_requirements_411008527_1040484407_205644721',
                  Archive.generate_key(HighLevelRequirement.all.first),
                  "Archive.generate_key((HighLevelRequirement.all.first)",
                  "    Expect Archive.archived((HighLevelRequirement.all.first) to be 'high_level_requirements_411008527_1040484407_205644721'). It was.")
    STDERR.puts('    The Archive correctly generated a key.')
  end

  test 'copy_attributes' do
    STDERR.puts('    Check to see that an Archive can correctly from one object to another.')

    attributes     = [
                        'reqid',
                        'full_id',
                        'description',
                        'category',
                        'verification_method',
                        'safety',
                        'robustness',
                        'derived',
                        'testmethod',
                        'version',
                        'item_id',
                        'project_id',
                        'system_requirement_associations',
                        'derived_justification',
                        'organization',
                        'archive_id',
                        'high_level_requirement_associations',
                        'soft_delete',
                        'document_id',
                        'model_file_id'
                     ]

    original_hlr   = HighLevelRequirement.all.first
    duplicated_hlr = HighLevelRequirement.new

    Archive.copy_attributes(original_hlr, duplicated_hlr, [])

    assert_equals(true,
                  compare_records(original_hlr, duplicated_hlr, attributes),
                  'High Level Requirement Records',
                  '    Expect High Level Requirement Records to match. They did.')
    STDERR.puts('    The Archive correctly copied attributes from one object to another.')
  end

  test 'save_object' do
    STDERR.puts('    Check to see that an object can be saved.')
    assert_not_equals_nil(Archive.save_object(ActionItem.all.first),
                          'ActionItem Record',
                          '    Expect save_object(ActionItem.all.first) to return an object. It did.')
    STDERR.puts('    An object was correctly saved.')
  end

  test 'get_unique_filename' do
    STDERR.puts('    Check to see that a unique filename can be generated.')
    assert_equals('test/fixtures/files/1-flowchart.png',
                  Archive.get_unique_filename('test/fixtures/files', 'flowchart.png'),
                  'ActionItem Record',
                  "    Expect Archive.get_unique_filename('test/fixtures/files/flowchart.png', 'flochart.png') to be test/fixtures/files/flowchart-01.png. It was.")
    STDERR.puts('    A unique filename was successfully generated.')
  end

  test 'clone_file' do
    STDERR.puts('    Check to see that an a file can be cloned.')

    source_code = SourceCode.new()

    Archive.copy_attributes(SourceCode.all.first, source_code,
                            [
                              'id',
                              'upload_file',
                              'url_type',
                              'url_description',
                              'url_link',
                              'file_path'
                             ])
    Archive.clone_file(SourceCode.all.first, source_code)
    assert_equals(true, source_code.upload_file.attached?,
                  'File Attached',
                  "    Expect upload_file.attached? to be true. It was.")
    STDERR.puts('    A file was successfully cloned.')
  end

  test 'clone_object' do
    STDERR.puts('    Check to see that an object can be cloned.')
    assert_not_equals_nil(Archive.clone_object(SourceCode.all.first),
                          'Cloned Oject',
                          "    Expect Cloned Object to be present. It was.")
    STDERR.puts('    An object was successfully cloned.')
  end

  test 'create_archive' do
    STDERR.puts('    Check to see that a complete Archive can be created.')
    clear_model_files
    assert_not_equals_nil(@archive.create_archive(@project.id),
                          'Archive',
                          "    Expect Archive to be present. It was.")
    STDERR.puts('    A complete Archive Item was successfully created.')
  end
end

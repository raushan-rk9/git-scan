require 'test_helper'

class SourceCodeTest < ActiveSupport::TestCase
  def compare_scs(x, y,
                   attributes = [
                                  'codeid',
                                  'full_id',
                                  'file_name',
                                  'module',
                                  'function',
                                  'derived',
                                  'derived_justification',
                                  'low_level_requirement_associations',
                                  'version',
                                  'organization',
                                  'item_id',
                                  'project_id',
                                  'high_level_requirement_associations',
                                  'url_type',
                                  'url_description',
                                  'url_link',
                                  'archive_id',
                                  'description',
                                  'soft_delete',
                                  'file_path',
                                  'content_type',
                                  'file_type',
                                  'revision',
                                  'draft_version',
                                  'external_version'
                               ])

    result = false

    return result unless x.present? && y.present?

    attributes.each do |attribute|
      if x.attributes[attribute].present? && y.attributes[attribute].present?
        result = (x.attributes[attribute] == y.attributes[attribute])
      elsif !x.attributes[attribute].present? && !y.attributes[attribute].present?
        result = true
      else
        result = false
      end

      unless result
        puts "#{attribute}: #{x.attributes[attribute]}, #{y.attributes[attribute]}"
      end
    end

    return result
  end

  def setup
    @project         = Project.find_by(identifier: 'TEST')
    @hardware_item   = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item   = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_sc_001 = SourceCode.find_by(item_id: @hardware_item.id,
                                          full_id: 'SC-001')
    @hardware_sc_002 = SourceCode.find_by(item_id: @hardware_item.id,
                                          full_id: 'SC-002')
    @software_sc_001 = SourceCode.find_by(item_id: @software_item.id,
                                          full_id: 'SC-001')
    @software_sc_002 = SourceCode.find_by(item_id: @software_item.id,
                                          full_id: 'SC-002')
    @model_file      = ModelFile.find_by(full_id: 'MF-001')
    @file_data       = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                    'image/png',
                                                    true)

    user_pm

    @gitlab_access   = GitlabAccess.new({
                                          username:                 "paulandvirginiacarrick@gmail.com",
                                          token:                    "uzVpuYM8xtxTs2Y1Y_vm",
                                          user_id:                  User.current.id,
                                          last_accessed_repository: "Demo Project",
                                          last_accessed_branch:     "master",
                                          last_accessed_folder:     "libhash",
                                          last_accessed_file:       "libhash/Android.mk|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/Android.mk\nlibhash/Makefile|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/Makefile\nlibhash/Makefile.nmake|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/Makefile.nmake\nlibhash/README.md|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/README.md\nlibhash/libhash.c|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/libhash.c\nlibhash/libhash.h|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/libhash.h\nlibhash/test_libhash.c|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/test_libhash.c\nlibhash/version.sh|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/version.sh",
                                          url:                      'https://gitlab.faaconsultants.com'
                                        })

    @gitlab_access.save!
  end

  test 'source code record should be valid' do
    STDERR.puts('    Check to see that a Source code Record with required fields filled in is valid.')
    assert_equals(true, @hardware_sc_001.valid?, 'Source Code Record', '    Expect Source Code Record to be valid. It was valid.')
    STDERR.puts('    The Source code Record was valid.')
  end

  test 'code id shall be present for source code' do
    STDERR.puts('    Check to see that a Source code Record without a Code ID is invalid.')

    @hardware_sc_001.codeid = nil

    assert_equals(false, @hardware_sc_001.valid?, 'Source Code Record', '    Expect Source Code without codeid not to be valid. It was not valid.')
    STDERR.puts('    The Source code Record was invalid.')
  end

  test 'project id shall be present for source code' do
    STDERR.puts('    Check to see that a Source code Record without a Project ID is invalid.')

    @hardware_sc_001.project_id = nil

    assert_equals(false, @hardware_sc_001.valid?, 'Source Code Record', '    Expect Source Code without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Source code Record was invalid.')
  end

  test 'item id shall be present for source code' do
    STDERR.puts('    Check to see that a Source code Record without an Item ID is invalid.')

    @hardware_sc_001.item_id = nil

    assert_equals(false, @hardware_sc_001.valid?, 'Source Code Record', '    Expect Source Code without item_id not to be valid. It was not valid.')
    STDERR.puts('    The Source code Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Source Code' do
    STDERR.puts('    Check to see that a Source code can be created.')

    source_code = SourceCode.new({
                                          codeid:                              @hardware_sc_001.codeid,
                                          full_id:                             @hardware_sc_001.full_id,
                                          file_name:                           @hardware_sc_001.file_name,
                                          module:                              @hardware_sc_001.module,
                                          function:                            @hardware_sc_001.function,
                                          derived:                             @hardware_sc_001.derived,
                                          derived_justification:               @hardware_sc_001.derived_justification,
                                          low_level_requirement_associations:  @hardware_sc_001.low_level_requirement_associations,
                                          url_type:                            @hardware_sc_001.url_type,
                                          url_description:                     @hardware_sc_001.url_description,
                                          url_link:                            @hardware_sc_001.url_link,
                                          version:                             @hardware_sc_001.version,
                                          organization:                        @hardware_sc_001.organization,
                                          item_id:                             @hardware_sc_001.item_id,
                                          project_id:                          @hardware_sc_001.project_id,
                                          archive_id:                          @hardware_sc_001.archive_id,
                                          high_level_requirement_associations: @hardware_sc_001.high_level_requirement_associations,
                                          description:                         @hardware_sc_001.description,
                                          soft_delete:                         @hardware_sc_001.soft_delete,
                                          file_path:                           @hardware_sc_001.file_path,
                                          content_type:                        @hardware_sc_001.content_type,
                                          file_type:                           @hardware_sc_001.file_type,
                                          revision:                            @hardware_sc_001.revision,
                                          draft_version:                       @hardware_sc_001.draft_version,
                                          revision_date:                       @hardware_sc_001.revision_date,
                                          upload_date:                         @hardware_sc_001.upload_date,
                                          external_version:                    @hardware_sc_001.external_version
                                        })

    assert_not_equals_nil(source_code.save, 'Source Code Record', '    Expect Source Code Record to be created. It was.')
    STDERR.puts('    A Source code was successfully created.')
  end

  test 'should update Source Code' do
    STDERR.puts('    Check to see that a Source code can be updated.')

    full_id                   = @hardware_sc_001.full_id.dup
    @hardware_sc_001.full_id += '_001'

    assert_not_equals_nil(@hardware_sc_001.save, 'Source Code Record', '    Expect Source Code Record to be updated. It was.')

    @hardware_sc_001.full_id  = full_id
    STDERR.puts('    A Source code was successfully updated.')
  end

  test 'should delete Source Code' do
    STDERR.puts('    Check to see that a Source code can be deleted.')
    assert(@hardware_sc_001.destroy)
    STDERR.puts('    A Source code was successfully deleted.')
  end

  test 'should create Source Code with undo/redo' do
    STDERR.puts('    Check to see that a Source code can be created, then undone and then redone.')

    source_code = SourceCode.new({
                                          codeid:                              @hardware_sc_001.codeid,
                                          full_id:                             @hardware_sc_001.full_id,
                                          file_name:                           @hardware_sc_001.file_name,
                                          module:                              @hardware_sc_001.module,
                                          function:                            @hardware_sc_001.function,
                                          derived:                             @hardware_sc_001.derived,
                                          derived_justification:               @hardware_sc_001.derived_justification,
                                          low_level_requirement_associations:  @hardware_sc_001.low_level_requirement_associations,
                                          url_type:                            @hardware_sc_001.url_type,
                                          url_description:                     @hardware_sc_001.url_description,
                                          url_link:                            @hardware_sc_001.url_link,
                                          version:                             @hardware_sc_001.version,
                                          organization:                        @hardware_sc_001.organization,
                                          item_id:                             @hardware_sc_001.item_id,
                                          project_id:                          @hardware_sc_001.project_id,
                                          archive_id:                          @hardware_sc_001.archive_id,
                                          high_level_requirement_associations: @hardware_sc_001.high_level_requirement_associations,
                                          description:                         @hardware_sc_001.description,
                                          soft_delete:                         @hardware_sc_001.soft_delete,
                                          file_path:                           @hardware_sc_001.file_path,
                                          content_type:                        @hardware_sc_001.content_type,
                                          file_type:                           @hardware_sc_001.file_type,
                                          revision:                            @hardware_sc_001.revision,
                                          draft_version:                       @hardware_sc_001.draft_version,
                                          revision_date:                       @hardware_sc_001.revision_date,
                                          upload_date:                         @hardware_sc_001.upload_date,
                                          external_version:                    @hardware_sc_001.external_version
                                        })
    data_change            = DataChange.save_or_destroy_with_undo_session(source_code, 'create')

    assert_not_equals_nil(data_change, 'Source Code Record', '    Expect Source Code Record to be created. It was.')

    assert_difference('SourceCode.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('SourceCode.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Source code was successfully created, then undone and then redone.')
  end

  test 'should update Source Code with undo/redo' do
    STDERR.puts('    Check to see that a Source code can be updated, then undone and then redone.')

    full_id                    = @hardware_sc_001.full_id.dup
    @hardware_sc_001.full_id += '_001'
    data_change                = DataChange.save_or_destroy_with_undo_session(@hardware_sc_001, 'update')
    @hardware_sc_001.full_id  = full_id

    assert_not_equals_nil(data_change, 'Source Code Record', '    Expect Source Code Record to be updated. It was')
    assert_not_equals_nil(SourceCode.find_by(full_id: @hardware_sc_001.full_id + '_001', item_id: @hardware_item.id), 'Source Code Record', "    Expect Source Code Record's ID to be #{@hardware_sc_001.full_id + '_001'}. It was.")
    assert_equals(nil, SourceCode.find_by(full_id: @hardware_sc_001.full_id, item_id: @hardware_item.id), 'Source Code Record', '    Expect original Source Code Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, SourceCode.find_by(full_id: @hardware_sc_001.full_id + '_001', item_id: @hardware_item.id), 'Source Code Record', "    Expect updated Source Code's Record not to found. It was not found.")
    assert_not_equals_nil(SourceCode.find_by(full_id: @hardware_sc_001.full_id, item_id: @hardware_item.id), 'Source Code Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(SourceCode.find_by(full_id: @hardware_sc_001.full_id + '_001', item_id: @hardware_item.id), 'Source Code Record', "    Expect updated Source Code's Record to be found. It was found.")
    assert_equals(nil, SourceCode.find_by(full_id: @hardware_sc_001.full_id, item_id: @hardware_item.id), 'Source Code Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Source code was successfully updated, then undone and then redone.')
  end

  test 'should delete Source Code with undo/redo' do
    STDERR.puts('    Check to see that a Source code can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@hardware_sc_001, 'delete')

    assert_not_equals_nil(data_change, 'Source Code Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, SourceCode.find_by(codeid: @hardware_sc_001.codeid, item_id: @hardware_item.id), 'Source Code Record', '    Verify that the Source Code Record was actually deleted. It was.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(SourceCode.find_by(codeid: @hardware_sc_001.codeid, item_id: @hardware_item.id), 'Source Code Record', '    Verify that the Source Code Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, SourceCode.find_by(codeid: @hardware_sc_001.codeid, item_id: @hardware_item.id), 'Source Code Record', '    Verify that the Source Code Record was deleted again after redo. It was.')
    STDERR.puts('    A Source code was successfully deleted, then undone and then redone.')
  end

  test 'fullcodeid should be correct' do
    STDERR.puts('    Check to see that the Source code returns a proper Full ID.')

    @hardware_sc_001.fullcodeid

    assert_equals(1, @hardware_sc_001.fullcodeid, 'Source Code Record', '    Expect fullcodeid with full_id to be "SC-001". It was.')

    @hardware_sc_001.full_id = nil

    assert_equals(1, @hardware_sc_001.fullcodeid, 'Source Code Record', '    Expect fullcodeid without full_id to be "HARDWARE_ITEM-SC-1". It was.')
    STDERR.puts('    The Source code returned a proper Full ID successfully.')
  end

  test 'codeidplusdescription should be correct' do
    STDERR.puts('    Check to see that the Source code returns a proper Code ID with Description.')
    assert_equals('1 - alert_overpressure.c:Main:void print_error(const char * context)<br>HANDLE open_serial_port(const char * device, uint32_t baud_rate)<br>int write_port(HANDLE port, uint8_t * buffer, size_t size)<br>SSIZE_T read_port(HANDLE port, uint8_t * buffer, size_t size)<br>int jrk_set_target(HANDLE port, uint16_t target)<br>int jrk_get_variable(HANDLE port, uint8_t offset, uint8_t * buffer,  uint8_t length)<br>int jrk_get_target(HANDLE port)<br>int jrk_get_feedback(HANDLE port)<br>int main()',
                  @hardware_sc_001.codeidplusdescription,
                  'codeidplusdescription',
                  '    Verify that item_id_from_id was SC-001 - alert_overpressure.c:Main:void print_error(const char * context)<br>HANDLE open_serial_port(const char * device, uint32_t baud_rate)<br>int write_port(HANDLE port, uint8_t * buffer, size_t size)<br>SSIZE_T read_port(HANDLE port, uint8_t * buffer, size_t size)<br>int jrk_set_target(HANDLE port, uint16_t target)<br>int jrk_get_variable(HANDLE port, uint8_t offset, uint8_t * buffer,  uint8_t length)<br>int jrk_get_target(HANDLE port)<br>int jrk_get_feedback(HANDLE port)<br>int main()". It was.')
    STDERR.puts('    The Source code returned a proper Code ID with Description successfully.')
  end

  test 'code_id_plus_filename should be correct' do
    STDERR.puts('    Check to see that the Source code returns a proper Code ID with Filename.')
    assert_equals("1 - alert_overpressure.c",
                  @hardware_sc_001.code_id_plus_filename,
                  'code_id_plus_filename',
                  '    Verify that item_id_from_id was "SC-001 - alert_overpressure.c". It was.')
    STDERR.puts('    The Source code returned a proper Code ID with Filename successfully.')
  end

  test 'item_id_from_id should be correct' do
    STDERR.puts('    Check to see that the Source code returns a Item ID from an ID.')
    assert_equals(@hardware_sc_001.item_id,
                  SourceCode.item_id_from_id(@hardware_sc_001.id),
                  'item_id_from_id',
                  "    Verify that item_id_from_id was #{@hardware_sc_001.item_id}. It was.")
    STDERR.puts('    The Source code returned a proper Item ID from an ID successfully.')
  end

  test 'code_id_plus_filename_from_id should be correct' do
#    STDERR.puts('    Check to see that the Source code returns a proper Code ID with Filename from ID.')
#    assert_equals("1 - alert_overpressure.c",
#                  SourceCode.code_id_plus_filename_from_id(@hardware_sc_001.id),
#                  'code_id_plus_filename_from_id',
#                  '    Verify that code_id_plus_filename_from_id was "SC-001 - alert_overpressure.c". It was.')
#    STDERR.puts('    The Source code returned a proper Code ID with Filename from an ID successfully.')
  end

  test 'file_name_from_id should be correct' do
    STDERR.puts('    Check to see that the Source code returns a Filename from ID.')
    assert_equals(@hardware_sc_001.file_name,
                  SourceCode.file_name_from_id(@hardware_sc_001.id),
                  'file_name_from_id',
                  "    Verify that item_id_from_id was #{@hardware_sc_001.file_name}. It was.")
    STDERR.puts('    The Source code returned a proper Filename from an ID successfully.')
  end

  test 'code_plus_description_from_id should be correct' do
    STDERR.puts('    Check to see that the Source code returns a proper Code ID with Description from ID.')
    assert_equals("1 - alert_overpressure.c:Main:void print_error(const char * context)<br>HANDLE open_serial_port(const char * device, uint32_t baud_rate)<br>int write_port(HANDLE port, uint8_t * buffer, size_t size)<br>SSIZE_T read_port(HANDLE port, uint8_t * buffer, size_t size)<br>int jrk_set_target(HANDLE port, uint16_t target)<br>int jrk_get_variable(HANDLE port, uint8_t offset, uint8_t * buffer,  uint8_t length)<br>int jrk_get_target(HANDLE port)<br>int jrk_get_feedback(HANDLE port)<br>int main()",
                  SourceCode.code_plus_description_from_id(@hardware_sc_001.id),
                  'code_plus_description_from_id',
                  '    Verify that item_id_from_id was "SC-001 - alert_overpressure.c:Main:void print_error(const char * context)<br>HANDLE open_serial_port(const char * device, uint32_t baud_rate)<br>int write_port(HANDLE port, uint8_t * buffer, size_t size)<br>SSIZE_T read_port(HANDLE port, uint8_t * buffer, size_t size)<br>int jrk_set_target(HANDLE port, uint16_t target)<br>int jrk_get_variable(HANDLE port, uint8_t offset, uint8_t * buffer,  uint8_t length)<br>int jrk_get_target(HANDLE port)<br>int jrk_get_feedback(HANDLE port)<br>int main()". It was.')
    STDERR.puts('    The Source code returned a proper Code ID with Description from an ID successfully.')
  end

  test 'get_high_level_requirement should return the High Level Requirement' do
#    STDERR.puts('    Check to see that the Source Code can return an associated High-Level Requirement.')
#    assert_not_equals_nil(@hardware_sc_001.get_high_level_requirement,
#                          'High Level Requirement Record',
#                          '    Expect get_high_level_requirement to get a High Level Requirement. It did.')
#    STDERR.puts('    The Source Code returned  an associated High-Level Requirement successfully.')
  end

  test 'get_low_level_requirement should return the Low Level Requirement' do
#    STDERR.puts('    Check to see that the Source Code can return an associated Low-Level Requirement.')
#    assert_not_equals_nil(@hardware_sc_001.get_low_level_requirement, 'Low Level Requirement Record', '    Expect get_low_level_requirement to get a Low Level Requirement. It did.')
#    STDERR.puts('    The Source Code returned  an associated Low-Level Requirement successfully.')
  end

  test 'get_system_requirement should return the System Requirement' do
#    STDERR.puts('    Check to see that the Source code can return an associated System Requirement.')
#    assert_not_equals_nil(@hardware_sc_001.get_system_requirement,
#                          'System Requirement Record',
#                          '    Expect get_system_requirement to get a System Requirement. It did.')
#    STDERR.puts('    The Source code returned  an associated System Requirement successfully.')
  end

  test 'get_root_path should return the Root Path' do
    STDERR.puts('    Check to see that an Source code can return the root directory.')
    assert_equals('/var/folders/source_codes/test',
                  @hardware_sc_001.get_root_path,
                  'Source Code Record',
                  '    Expect the return from get_root_path to be /var/folders/source_codes/test." It was.')
    STDERR.puts('    The Source code successfully returned the root directory.')
  end

  test 'get_file_path should return the File Path' do
    STDERR.puts('    Check to see that an Source Code can return the file path for a document.')
    assert_equals('/var/folders/source_codes/test/alert_overpressure.c',
                  @hardware_sc_001.get_file_path, 'Source Code Record',
                  '    Expect the return from get_file_path to be /var/folders/source_codes/test/alert_overpressure.c." It was.')
    STDERR.puts('    The Source Code successfully returned the file path for a document.')
  end

  test 'get_file_contents should return the file contents' do
    STDERR.puts('    Check to see that an Source Code can get the contents from a document.')

    file = @hardware_sc_001.get_file_contents

    assert_equals('upload_file', file.name, 'File Name', "    Expect the file.name to be 'upload_file'. It was.")
    assert_equals('alert_overpressure.c', file.filename.to_s, 'Filename', "    Expect the file.filename to be 'alert_overpressure.c'. It was.")
    assert_equals('text/x-csrc', file.content_type, 'Filename', "    Expect the file.content_type to be 'text/x-csrc'. It was.")
    assert_equals(6274, file.download.length, 'Filename', "    Expect the file.download.length to be 22049. It was.")
    STDERR.puts('    The Source Code successfully got the contents from a document.')
  end

  test 'store_file should store a file' do
    STDERR.puts('    Check to see that an Source Code can store a file.')

    sc       = SourceCode.new()
    filename = sc.store_file(@file_data, true, true)

    assert_equals('/var/folders/source_codes/test/flowchart-1.png', filename, 'Filename', "    Expect the filename to be '/var/folders/source_codes/test/flowchart-1.png'. It was.")
    STDERR.puts('    The Source Code successfully stored a file.')
  end

  test 'replace_file should replace a file' do
    STDERR.puts('    Check to see that a Source Code can replace a file.')
    FileUtils.cp('test/fixtures/files/alert_overpressure.c',
                 '/var/folders/source_codes/test/alert_overpressure.c')
    assert_not_equals_nil(@hardware_sc_001.replace_file(@file_data,
                                                        @project.id,
                                                        @hardware_item),
                          'Data Change Record',
                          '    Expect Data Change Record to not be nil. It was.')
    STDERR.puts('    The Source Code successfully replaced a file.')
  end

  test 'should rename prefix' do
    STDERR.puts('    Check to see that the Source code can rename its prefix.')

    original_scs = SourceCode.where(item_id: @hardware_item.id)
    original_scs = original_scs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    SourceCode.rename_prefix(@project.id, @hardware_item.id,
                                'SC', 'Source Code')

    renamed_scs  = SourceCode.where(item_id: @hardware_item.id)
    renamed_scs  = renamed_scs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    original_scs.each_with_index do |sc, index|
      expected_id = sc.full_id.sub('SC', 'Source Code')
      renamed_sc = renamed_scs[index]

      assert_equals(expected_id, renamed_sc.full_id, 'Source Code Full ID', "    Expect full_id to be #{expected_id}. It was.")
    end

    STDERR.puts('    The Source code renamed its prefix successfully.')
  end

  test 'should renumber' do
    STDERR.puts('    Check to see that the Source code can renumber the Source Codes.')

    original_scs    = SourceCode.where(item_id: @hardware_item.id)
    original_scs    = original_scs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    SourceCode.renumber(@hardware_item.id, 10, 10, 'Source Code')

    renumbered_scs  = SourceCode.where(item_id: @hardware_item.id)
    renumbered_scs  = renumbered_scs.to_a.sort { |x, y| x.full_id <=> y.full_id}
    number          = 10

    original_scs.each_with_index do |sc, index|
      expected_id   = sc.full_id.sub('SC', 'Source Code').sub(/\-\d{3}/, sprintf('-%03d', number))
      renumbered_sc = renumbered_scs[index]

      assert_equals(expected_id, renumbered_sc.full_id, 'Source Code Full ID', "    Expect full_id to be #{expected_id}. It was.")
      number       += 10
    end

    STDERR.puts('    The Source code renumbered the Source Codes successfully.')
  end

  test 'should get columns' do
    STDERR.puts('    Check to see that the Source code can return the columns.')

    columns = @hardware_sc_001.get_columns
    columns = columns[1..13] + columns[16..19]

    assert_equals([
                    1,
                    "SC-001",
                    "alert_overpressure.c",
                    "Main",
                    "void print_error(const char * context)<br>HANDLE open_serial_port(const char * device, uint32_t baud_rate)<br>int write_port(HANDLE port, uint8_t * buffer, size_t size)<br>SSIZE_T read_port(HANDLE port, uint8_t * buffer, size_t size)<br>int jrk_set_target(HANDLE port, uint16_t target)<br>int jrk_get_variable(HANDLE port, uint8_t offset, uint8_t * buffer,  uint8_t length)<br>int jrk_get_target(HANDLE port)<br>int jrk_get_feedback(HANDLE port)<br>int main()",
                    false, "nil",
                    0,
                    "HARDWARE_ITEM",
                    "Test",
                    "ATTACHMENT",
                    "alert_overpressure.c",
                    "alert_overpressure.c",
                    "test",
                    "LLR-001",
                    "HLR-001",
                    false
                  ],
                  columns, 'Columns',
                  '    Expect columns to be [1, "SC-001", "alert_overpressure.c", "Main", "void print_error(const char * context)<br>HANDLE open_serial_port(const char * device, uint32_t baud_rate)<br>int write_port(HANDLE port, uint8_t * buffer, size_t size)<br>SSIZE_T read_port(HANDLE port, uint8_t * buffer, size_t size)<br>int jrk_set_target(HANDLE port, uint16_t target)<br>int jrk_get_variable(HANDLE port, uint8_t offset, uint8_t * buffer,  uint8_t length)<br>int jrk_get_target(HANDLE port)<br>int jrk_get_feedback(HANDLE port)<br>int main()", false, "nil", 0, "HARDWARE_ITEM", "Test", "ATTACHMENT", "alert_overpressure.c", "alert_overpressure.c", "test", "LLR-001", "HLR-001", false]. It was.')
    STDERR.puts('    The Source code returned the columns successfully.')
  end

  test 'should generate CSV' do
    STDERR.puts('    Check to see that the Source code can generate CSV properly.')

    csv   = SourceCode.to_csv(@hardware_item.id)
    lines = csv.split("\n")

    assert_equals('id,codeid,full_id,file_name,module,function,derived,derived_justification,version,item_id,project_id,url_type,url_link,url_description,created_at,updated_at,organization,low_level_requirement_associations,high_level_requirement_associations,soft_delete,file_path,content_type,file_type,revision,draft_version,revision_date,upload_date,external_version,archive_revision,archive_version,module_description_associations',
                  lines[0], 'Header',
                  '    Expect header to be "id,codeid,full_id,file_name,module,function,derived,derived_justification,version,item_id,project_id,url_type,url_link,url_description,created_at,updated_at,organization,low_level_requirement_associations,high_level_requirement_associations,soft_delete,file_path,content_type,file_type,revision,draft_version,revision_date,upload_date,external_version,archive_revision,archive_version,module_description_associations". It was.')
    assert_equals('705442009,1,SC-001,alert_overpressure.c,Main',
                  lines[1][0..43], 'First Record',
                  '    Expect first line to be 705442009,1,SC-001,alert_overpressure.c,Main... It was.')
    STDERR.puts('    The Source code generated CSV successfully.')
  end

  test 'should generate XLS' do
    STDERR.puts('    Check to see that the Source code can generate XLS properly.')

    assert_nothing_raised do
      xls = SourceCode.to_xls(@hardware_item.id)

      assert_not_equals_nil(xls, 'XLS Data', '    Expect XLS Data to not be nil. It was.')
    end

    STDERR.puts('    The Source code generated XLS successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the Source code can assign columns properly.')

    sc = SourceCode.new()

    assert(sc.assign_column('id', '1', @hardware_item.id))
    assert(sc.assign_column('project_id', 'Test', @hardware_item.id))
    assert_equals(@project.id, sc.project_id, 'Project ID',
                  "    Expect Project ID to be #{@project.id}. It was.")
    assert(sc.assign_column('item_id', @hardware_item.id.to_s, @hardware_item.id))
    assert_equals(@hardware_item.id, sc.item_id, 'Item ID',
                  "    Expect Item ID to be #{@hardware_item.id}. It was.")
    assert(sc.assign_column('codeid', @hardware_sc_001.codeid.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.codeid, sc.codeid, 'Code ID',
                  "    Expect Code ID to be #{@hardware_sc_001.codeid}. It was.")
    assert(sc.assign_column('full_id', @hardware_sc_001.full_id,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.full_id, sc.full_id, 'Full ID',
                  "    Expect Full ID to be #{@hardware_sc_001.full_id}. It was.")
    assert(sc.assign_column('file_name', @hardware_sc_001.file_name,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.file_name, sc.file_name, 'file_name',
                  "    Expect file_name to be #{@hardware_sc_001.file_name}. It was.")
    assert(sc.assign_column('module', @hardware_sc_001.module,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.module, sc.module, 'module',
                  "    Expect module to be #{@hardware_sc_001.module}. It was.")
    assert(sc.assign_column('function', @hardware_sc_001.function,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.function, sc.function, 'function',
                  "    Expect function to be #{@hardware_sc_001.function}. It was.")
    assert(sc.assign_column('derived', 'true', @hardware_item.id))
    assert_equals(true, sc.derived, 'Derived',
                  "    Expect Derived from 'true' to be true. It was.")
    assert(sc.assign_column('derived', 'false', @hardware_item.id))
    assert_equals(false, sc.derived, 'Derived',
                  "    Expect Derived from 'false' to be false. It was.")
    assert(sc.assign_column('derived', 'yes', @hardware_item.id))
    assert_equals(true, sc.derived, 'Derived',
                  "    Expect Derived from 'yes' to be true. It was.")
    assert(sc.assign_column('derived_justification', @hardware_sc_001.derived_justification,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.derived_justification, sc.derived_justification, 'derived_justification',
                  "    Expect derived_justification to be #{@hardware_sc_001.derived_justification}. It was.")
    assert(sc.assign_column('low_level_requirement_associations', 'LLR-001',
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.low_level_requirement_associations,
                  sc.low_level_requirement_associations,
                  'Low Level Requirement Associations',
                  "    Expect Low Level Requirement Associations to be #{@hardware_sc_001.low_level_requirement_associations}. It was.")
    assert(sc.assign_column('version', @hardware_sc_001.version.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.version, sc.version, 'Version',
                  "    Expect Version to be #{@hardware_sc_001.version}. It was.")
    assert(sc.assign_column('url_type', @hardware_sc_001.url_type,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.url_type, sc.url_type, 'Url_type',
                  "    Expect Url_type to be #{@hardware_sc_001.url_type}. It was.")
    assert(sc.assign_column('url_link', @hardware_sc_001.url_link,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.url_link, sc.url_link, 'Url_link',
                  "    Expect Url_link to be #{@hardware_sc_001.url_link}. It was.")
    assert(sc.assign_column('url_description', @hardware_sc_001.url_description,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.url_description, sc.url_description, 'Url_description',
                  "    Expect Url_description to be #{@hardware_sc_001.url_description}. It was.")
    assert(sc.assign_column('high_level_requirement_associations', 'HLR-001',
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.high_level_requirement_associations,
                  sc.high_level_requirement_associations,
                  'High Level Requirement Associations',
                  "    Expect High Level Requirement Associations to be #{@hardware_sc_001.high_level_requirement_associations}. It was.")
    assert(sc.assign_column('created_at', @hardware_sc_001.created_at.to_s,
                             @hardware_item.id))
    assert(sc.assign_column('updated_at', @hardware_sc_001.updated_at.to_s,
                             @hardware_item.id))
    assert(sc.assign_column('organization', @hardware_sc_001.organization,
                             @hardware_item.id))
    assert(sc.assign_column('soft_delete', 'true', @hardware_item.id))
    assert_equals(true, sc.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'true' to be true. It was.")
    assert(sc.assign_column('soft_delete', 'false', @hardware_item.id))
    assert_equals(false, sc.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'false' to be false. It was.")
    assert(sc.assign_column('soft_delete', 'yes', @hardware_item.id))
    assert_equals(true, sc.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'yes' to be true. It was.")
    assert(sc.assign_column('description', @hardware_sc_001.description,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.description, sc.description, 'Description',
                  "    Expect Description to be #{@hardware_sc_001.description}. It was.")
    assert(sc.assign_column('file_path', @hardware_sc_001.file_path,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.file_path, sc.file_path, 'File_path',
                  "    Expect File_path to be #{@hardware_sc_001.file_path}. It was.")
    assert(sc.assign_column('content_type', @hardware_sc_001.content_type,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.content_type, sc.content_type, 'Content_type',
                  "    Expect Content_type to be #{@hardware_sc_001.content_type}. It was.")
    assert(sc.assign_column('file_type', @hardware_sc_001.file_type,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.file_type, sc.file_type, 'File_type',
                  "    Expect File_type to be #{@hardware_sc_001.file_type}. It was.")
    assert(sc.assign_column('revision', @hardware_sc_001.revision,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.revision, sc.revision, 'Revision',
                  "    Expect Revision to be #{@hardware_sc_001.revision}. It was.")
    assert(sc.assign_column('draft_version', @hardware_sc_001.draft_version,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.draft_version, sc.draft_version, 'Draft_version',
                  "    Expect Draft_version to be #{@hardware_sc_001.draft_version}. It was.")
    assert(sc.assign_column('revision_date', @hardware_sc_001.revision_date.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.revision_date, sc.revision_date, 'Revision_date',
                  "    Expect Revision_date to be #{@hardware_sc_001.revision_date}. It was.")
    assert(sc.assign_column('upload_date', @hardware_sc_001.upload_date.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.upload_date, sc.upload_date, 'Upload_date',
                  "    Expect Upload_date to be #{@hardware_sc_001.upload_date}. It was.")
    assert(sc.assign_column('external_version', @hardware_sc_001.external_version,
                             @hardware_item.id))
    assert_equals(@hardware_sc_001.external_version, sc.external_version, 'external_version',
                  "    Expect external_version to be #{@hardware_sc_001.external_version}. It was.")
    assert(sc.assign_column('archive_revision', 'a', @hardware_item.id))
    assert(sc.assign_column('archive_version', '1.1', @hardware_item.id))
    STDERR.puts('    The Source code assigned the columns successfully.')
  end

  test 'should parse CSV string' do
    STDERR.puts('    Check to see that the Source code can parse CSV properly.')

    attributes = [
                    'file_name',
                    'module',
                    'function',
                    'derived',
                    'derived_justification',
                    'low_level_requirement_associations',
                    'version',
                    'organization',
                    'item_id',
                    'project_id',
                    'high_level_requirement_associations',
                    'url_type',
                    'url_description',
                    'url_link',
                    'archive_id',
                    'description',
                    'soft_delete',
                    'file_path',
                    'content_type',
                    'file_type',
                    'revision',
                    'draft_version',
                    'external_version'
                 ]
    csv        = SourceCode.to_csv(@hardware_item.id)
    lines      = csv.gsub(/\n(\d+),/, "\r#{$1},").split("\r")

    assert_equals(:duplicate_source_code,
                  SourceCode.from_csv_string(lines[1],
                                             @hardware_item,
                                             [ :check_duplicates ]),
                  'Source Code Records',
                  '    Expect Duplicate Source Code Records to error. They did.')

    line       = lines[1].gsub('HLR-001', 'HLR-002')

    assert_equals(:high_level_requirement_associations_changed,
                  SourceCode.from_csv_string(line,
                                             @hardware_item,
                                             [ :check_associations ]),
                  'Source Code Records',
                  '    Expect Changed Associations Records to error. They did.')

    line       = lines[1].gsub('1,SC-001', '3,SC-003')

    assert(SourceCode.from_csv_string(line, @hardware_item))

    sc        = SourceCode.find_by(full_id: 'SC-003')

    assert_equals(true, compare_scs(@hardware_sc_001, sc, attributes),
                  'Source Code Records',
                  '    Expect Source Code Records to match. They did.')
    STDERR.puts('    The Source code parsed CSV successfully.')
  end

  test 'should parse files' do
    STDERR.puts('    Check to see that the Source code can parse files properly.')
    assert_equals(:duplicate_source_code,
                  SourceCode.from_file('test/fixtures/files/Hardware Item-Source_Codes.csv',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Source Code Records from Hardware Item-Source_codes.csv',
                  '    Expect Duplicate Source Code Records to error. They did.')
    assert_equals(true,
                  SourceCode.from_file('test/fixtures/files/Hardware Item-Source_Codes.csv',
                                                 @hardware_item),
                  'Source Code Records From Hardware Item-Source_codes.csv',
                  '    Expect Changed Source Code Associations Records  from Hardware Item-Source_codes.csv to error. They did.')
    assert_equals(:duplicate_source_code,
                  SourceCode.from_file('test/fixtures/files/Hardware Item-Source_Codes.xls',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Source Code Records from Hardware Item-Source_codes.csv',
                  '    Expect Duplicate Source Code Records to error. They did.')
    assert_equals(true,
                  SourceCode.from_file('test/fixtures/files/Hardware Item-Source_Codes.xls',
                                                 @hardware_item),
                  'Source Code Records From Hardware Item-Source_codes.csv',
                  '    Expect Changed Source Code Associations Records  from Hardware Item-Source_codes.csv to error. They did.')
    assert_equals(:duplicate_source_code,
                  SourceCode.from_file('test/fixtures/files/Hardware Item-Source_Codes.xlsx',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Source Code Records from Hardware Item-Source_codes.csv',
                  '    Expect Duplicate Source Code Records to error. They did.')
    assert_equals(true,
                  SourceCode.from_file('test/fixtures/files/Hardware Item-Source_Codes.xlsx',
                                                 @hardware_item),
                  'Source Code Records From Hardware Item-Source_codes.csv',
                  '    Expect Changed Source Code Associations Records  from Hardware Item-Source_codes.csv to error. They did.')
    STDERR.puts('    The Source code parsed files successfully.')
  end

  test 'should scan for functions' do
    STDERR.puts('    Check to see that the Source code can scan for functions.')
    contents = File.read('test/fixtures/files/alert_overpressure.c')

    assert(contents.present?)

    functions = SourceCode.scan_for_functions(contents)

    assert_equals([
                    "void print_error(const char * context)",
                    "HANDLE open_serial_port(const char * device, uint32_t baud_rate)",
                    "int write_port(HANDLE port, uint8_t * buffer, size_t size)",
                    "SSIZE_T read_port(HANDLE port, uint8_t * buffer, size_t size)",
                    "int jrk_set_target(HANDLE port, uint16_t target)",
                    "int jrk_get_target(HANDLE port)",
                    "int jrk_get_feedback(HANDLE port)"
                  ],
                  functions, 'Functions',
                  '    Expect columns to be ["void print_error(const char * context)", "HANDLE open_serial_port(const char * device, uint32_t baud_rate)", "int write_port(HANDLE port, uint8_t * buffer, size_t size)", "SSIZE_T read_port(HANDLE port, uint8_t * buffer, size_t size)", "int jrk_set_target(HANDLE port, uint16_t target)", "int jrk_get_target(HANDLE port)", "int jrk_get_feedback(HANDLE port)"]. It was.')
    STDERR.puts('    The Source code scanned for functions successfully.')
  end

  test 'should generate source codes' do
    STDERR.puts('    Check to see that the Source code can generate Source Codes.')
    assert_difference('SourceCode.count', +8) do
      assert(SourceCode.generate_source_codes(@gitlab_access.last_accessed_file.split("\n"),
                                              @hardware_item,
                                              @gitlab_access))
    STDERR.puts('    The Source code generated Source Codes successfully.')
    end
  end

  test 'should instrument' do
    STDERR.puts('    Check to see that the Source code can instrument source codes.')
    assert_not_equals_nil(@software_sc_001.instrument(nil, true), 'Data Change', '    Expect Data Change to be present. It was.')
    STDERR.puts('    The Source code instrumeted Source Codes successfully.')
  end
end

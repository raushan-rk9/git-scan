require 'test_helper'

class ModelFileTest < ActiveSupport::TestCase
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

  test 'model file record should be valid' do
    STDERR.puts('    Check to see that a Model file Record with required fields filled in is valid.')
    assert_equals(true, @model_file_001.valid?, 'Model File Record', '    Expect Model File Record to be valid. It was valid.')
    assert_equals(true, @model_file_002.valid?, 'Model File Record', '    Expect Model File Record to be valid. It was valid.')
    STDERR.puts('    The Model file Record was valid.')
  end

  test 'model id shall be present for model file' do
    STDERR.puts('    Check to see that a Model file Record without a Model ID is invalid.')

    @model_file_001.model_id = nil

    assert_equals(false, @model_file_001.valid?, 'Model File Record', '    Expect Model File without model_id not to be valid. It was not valid.')
    STDERR.puts('    The Model file Record was invalid.')
  end

  test 'project id shall be present for model file' do
    STDERR.puts('    Check to see that a Model file Record without a Project ID is invalid.')

    @model_file_001.project_id = nil

    assert_equals(false, @model_file_001.valid?, 'Model File Record', '    Expect Model File without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Model file Record was invalid.')
  end

  test 'full id shall be present for model file' do
    STDERR.puts('    Check to see that a Model file Record without a Full ID is invalid.')

    @model_file_001.full_id = nil

    assert_equals(false, @model_file_001.valid?, 'Model File Record', '    Expect Model File without Full ID not to be valid. It was not valid.')
    STDERR.puts('    The Model file Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Model File' do
    STDERR.puts('    Check to see that a Model file can be created.')

    model_file = ModelFile.new({
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
                                })

    assert_not_equals_nil(model_file.save, 'Model File Record', '    Expect Model File Record to be created. It was.')
    STDERR.puts('    A Model file was successfully created.')
  end

  test 'should update Model File' do
    STDERR.puts('    Check to see that a Model file can be updated.')

    @model_file_001.full_id  = @model_file_001.full_id.dup
    @model_file_001.model_id = 3
    @model_file_001.full_id  = 'MF-003',

    assert_not_equals_nil(@model_file_001.save, 'Model File Record', '    Expect Model File Record to be updated. It was.')
    STDERR.puts('    A Model file was successfully updated.')
  end

  test 'should delete Model File' do
    STDERR.puts('    Check to see that a Model file can be deleted.')
    unlink_model_file(@model_file_001.id)
    assert(@model_file_001.destroy)
    assert(@model_file_002.destroy)
    STDERR.puts('    A Model file was successfully deleted.')
  end

  test 'should create Model File with undo/redo' do
    STDERR.puts('    Check to see that a Model file can be created, then undone and then redone.')

    model_file  = ModelFile.new({
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
                                })
    data_change = DataChange.save_or_destroy_with_undo_session(model_file, 'create')

    assert_not_equals_nil(data_change, 'Model File Record',
                          '    Expect Model File Record to be created. It was.')

    assert_difference('ModelFile.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('ModelFile.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Model file was successfully created, then undone and then redone.')
  end

  test 'should update Model File with undo/redo' do
    STDERR.puts('    Check to see that a Model file can be updated, then undone and then redone.')

    full_id                 = @model_file_001.full_id.dup
    @model_file_001model_id = 3
    @model_file_001.full_id = 'MF-003'
    data_change             = DataChange.save_or_destroy_with_undo_session(@model_file_001, 'update')
    @model_file_001.full_id = full_id

    assert_not_equals_nil(data_change, 'Model File Record',
                          '    Expect Model File Record to be updated. It was')
    assert_not_equals_nil(ModelFile.find_by(full_id: 'MF-003'),
                          'Model File Record',
                          "    Expect Model File Record's ID to be MF-003. It was.")
    assert_equals(nil, ModelFile.find_by(full_id: full_id), 'Model File Record',
                  '    Expect original Model File Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, ModelFile.find_by(full_id: 'MF-003'),
                  'Model File Record',
                  "    Expect updated Model File's Record not to found. It was not found.")
    assert_not_equals_nil(ModelFile.find_by(full_id: full_id),
                          'Model File Record',
                          '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(ModelFile.find_by(full_id: 'MF-003'),
                          'Model File Record',
                          "    Expect updated Model File's Record to be found. It was found.")
    assert_equals(nil, ModelFile.find_by(full_id: full_id), 'Model File Record',
                  '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Model file was successfully updated, then undone and then redone.')
  end

  test 'should delete Model File with undo/redo' do
    STDERR.puts('    Check to see that a Model file can be deleted, then undone and then redone.')
    unlink_model_file(@model_file_001.id)

    data_change = DataChange.save_or_destroy_with_undo_session(@model_file_001,
                                                               'delete')

    assert_not_equals_nil(data_change, 'Model File Record',
                          '    Expect that the delete succeded. It did.')
    assert_equals(nil, ModelFile.find_by(model_id: @model_file_001.model_id),
                  'Model File Record',
                  '    Verify that the Model File Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(ModelFile.find_by(model_id: @model_file_001.model_id),
                          'Model File Record',
                          '    Verify that the Model File Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, ModelFile.find_by(model_id: @model_file_001.model_id),
                  'Model File Record',
                  '    Verify that the Model File Record was deleted again after redo. It was.')
    STDERR.puts('    A Model file was successfully deleted, then undone and then redone.')
  end

  test 'full_id_from_id should be correct' do
    STDERR.puts('    Check to see that the Model file returns a Full ID from an ID.')
    assert_equals(@model_file_001.full_id,
                  ModelFile.full_id_from_id(@model_file_001.id),
                  'full_id_from_id',
                  "    Verify that item_id_from_id was #{@model_file_001.item_id}. It was.")
    assert_equals(@model_file_002.full_id,
                  ModelFile.full_id_from_id(@model_file_002.id),
                  'full_id_from_id',
                  "    Verify that item_id_from_id was #{@model_file_002.item_id}. It was.")
    STDERR.puts('    The Model file returned a proper Item ID from an ID successfully.')
  end

  test 'id_from_full_id should be correct' do
    STDERR.puts('    Check to see that the Model file returns a Full ID from an ID.')
    assert_equals(@model_file_001.id,
                  ModelFile.id_from_full_id(@model_file_001.full_id),
                  'id_from_full_id',
                  "    Verify that item_id_from_id was #{@model_file_001.id}. It was.")
    assert_equals(@model_file_002.id,
                  ModelFile.id_from_full_id(@model_file_002.full_id),
                  'id_from_full_id',
                  "    Verify that item_id_from_id was #{@model_file_002.id}. It was.")
    STDERR.puts('    The Model file returned a proper  ID from a Full ID successfully.')
  end

  test 'full_model_id should be correct' do
    STDERR.puts('    Check to see that the Model file returns a proper File ID with Filename from ID.')
    assert_equals('MF-001', @model_file_001.full_model_id,
                  'full_model_id',
                  '    Verify that file_id_plus_filename_from_id was "MF-001 - Model File". It was.')
    assert_equals('MF-002', @model_file_002.full_model_id,
                  'full_model_id',
                  '    Verify that file_id_plus_filename_from_id was "MF-002 - Model File". It was.')
    STDERR.puts('    The Model file returned a proper File ID with Filename from an ID successfully.')
  end

  test 'full_model_id_plus_description should be correct' do
    STDERR.puts('    Check to see that the Model file returns a proper Full Model ID with Description from ID.')
    assert_equals('MF-001 - Model File',
                  @model_file_001.full_model_id_plus_description,
                  'full_model_id_plus_description',
                  '    Verify that full_model_id_plus_description was "MF-001 - Model File". It was.')
    assert_equals('MF-002 - Model File',
                  @model_file_002.full_model_id_plus_description,
                  'full_model_id_plus_description',
                  '    Verify that full_model_id_plus_description was "MF-002 - Model File". It was.')
    STDERR.puts('    The Model file returned a proper Full Model ID with Description from an ID successfully.')
  end

  test 'get_system_requirement should return the System Requirement' do
    STDERR.puts('    Check to see that the Model FIle can return an associated System Requirement.')
    assert_not_equals_nil(@model_file_001.get_system_requirement,
                          'System Requirement Record',
                          '    Expect get_system_requirement to get a System Requirement. It did.')
    assert_not_equals_nil(@model_file_002.get_system_requirement,
                          'System Requirement Record',
                          '    Expect get_system_requirement to get a System Requirement. It did.')
    STDERR.puts('    The Model File got an associated System Requirement successfully.')
  end

  test 'get_high_level_requirement should return the High Level Requirement' do
    STDERR.puts('    Check to see that the Model File can return an associated High-Level Requirement.')
    assert_not_equals_nil(@model_file_001.get_high_level_requirement,
                          'High Level Requirement Record',
                          '    Expect get_high_level_requirement to get a High Level Requirement. It did.')
    assert_not_equals_nil(@model_file_002.get_high_level_requirement,
                          'High Level Requirement Record',
                          '    Expect get_high_level_requirement to get a High Level Requirement. It did.')
    STDERR.puts('    The Model File returned  an associated High-Level Requirement successfully.')
  end

  test 'get_low_level_requirement should return the Low Level Requirement' do
    STDERR.puts('    Check to see that the Model File can return an associated Low-Level Requirement.')
    assert_not_equals_nil(@model_file_001.get_low_level_requirement, 'Low Level Requirement Record', '    Expect get_low_level_requirement to get a Low Level Requirement. It did.')
    assert_not_equals_nil(@model_file_002.get_low_level_requirement, 'Low Level Requirement Record', '    Expect get_low_level_requirement to get a Low Level Requirement. It did.')
    STDERR.puts('    The Model File returned  an associated Low-Level Requirement successfully.')
  end

  test 'get_test_case should return the Test Case' do
    STDERR.puts('    Check to see that the Model file can return an associated Test Case.')
    assert_not_equals_nil(@model_file_001.get_test_case,
                          'Test Case Record',
                          '    Expect get_test_case to get a Test Case. It did.')
    assert_not_equals_nil(@model_file_002.get_test_case,
                          'Test Case Record',
                          '    Expect get_test_case to get a Test Case. It did.')
    STDERR.puts('    The Model file returned  an associated Test Case successfully.')
  end

  test 'get_root_path should return the Root Path' do
    STDERR.puts('    Check to see that an Model file can return the root directory.')
    assert_equals('/var/folders/model_files/test',
                  @model_file_001.get_root_path,
                  'Model File Record',
                  '    Expect the return from get_root_path to be /var/folders/model_files/test." It was.')
    STDERR.puts('    The Model file successfully returned the root directory.')
  end

  test 'get_file_path should return the File Path' do
    STDERR.puts('    Check to see that an Model File can return the file path for a document.')
    assert_equals('/var/folders/model_files/test/Screen Shot 2020-03-31 at 2.15.15 PM.png',
                  @model_file_001.get_file_path, 'Model File Record',
                  '    Expect the return from get_file_path to be /var/folders/model_files/test/Screen Shot 2020-03-31 at 2.15.15 PM.png." It was.')
    STDERR.puts('    The Model File successfully returned the file path for a document.')
  end

  test 'get_file_contents should return the file contents' do
    STDERR.puts('    Check to see that an Model File can get the contents from a file.')

    file = @model_file_001.get_file_contents

    assert_equals('upload_file', file.name, 'File Name', "    Expect the file.name to be 'upload_file'. It was.")
    assert_equals('Screen Shot 2020-03-31 at 2.15.15 PM.png', file.filename.to_s, 'Filename', "    Expect the file.filename to be 'Screen Shot 2020-03-31 at 2.15.15 PM.png'. It was.")
    assert_equals('image/png', file.content_type, 'Filename', "    Expect the file.content_type to be 'image/png'. It was.")
    assert_equals(136121, file.download.length, 'Filename', "    Expect the file.download.length to be 136121. It was.")
    STDERR.puts('    The Model File successfully got the contents from a file.')
  end

  test 'store_file should store a file' do
    STDERR.puts('    Check to see that an Model File can store a file.')

    sc       = ModelFile.new()
    filename = sc.store_file(@file_data, true, true)

    assert_equals('/var/folders/model_files/test/flowchart-1.png', filename, 'Filename', "    Expect the filename to be '/var/folders/model_files/test/flowchart-1.png'. It was.")
    STDERR.puts('    The Model File successfully stored a file.')
  end

  test 'replace_file should replace a file' do
    STDERR.puts('    Check to see that an Model File can replace a file.')

    FileUtils.cp('test/fixtures/files/alert_overpressure.c',
                 '/var/folders/model_files/test/alert_overpressure.c')
    assert_not_equals_nil(@model_file_001.replace_file(@file_data,
                                                   @project.id,
                                                   nil),
                          'Data Change Record',
                          '    Expect Data Change Record to not be nil. It was.')
    STDERR.puts('    The Model File successfully replace a file.')
  end

  test 'should rename prefix' do
    STDERR.puts('    Check to see that the Model file can rename its prefix.')
    original_scs = ModelFile.where(item_id: @hardware_item.id)
    original_scs = original_scs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    ModelFile.rename_prefix(@project.id, @hardware_item.id,
                                'MF', 'Model File')

    renamed_scs  = ModelFile.where(item_id: @hardware_item.id)
    renamed_scs  = renamed_scs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    original_scs.each_with_index do |sc, index|
      expected_id = sc.full_id.sub('MF', 'Model File')
      renamed_sc = renamed_scs[index]

      assert_equals(expected_id, renamed_sc.full_id, 'Model File Full ID', "    Expect full_id to be #{expected_id}. It was.")
    end

    STDERR.puts('    The Model file renamed its prefix successfully.')
  end

  test 'should renumber' do
    STDERR.puts('    Check to see that the Model file can renumber the Model Files.')
    original_scs    = ModelFile.where(item_id: @hardware_item.id)
    original_scs    = original_scs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    ModelFile.renumber(:project, @project.id, 10, 10, 'Model File')

    renumbered_scs  = ModelFile.where(project_id: @project.id)
    renumbered_scs  = renumbered_scs.to_a.sort { |x, y| x.full_id <=> y.full_id}
    number          = 10

    original_scs.each_with_index do |sc, index|
      expected_id   = sc.full_id.sub('MF', 'Model File').sub(/\-\d{3}/, sprintf('-%03d', number))
      renumbered_sc = renumbered_scs[index]

      assert_equals(expected_id, renumbered_sc.full_id, 'Model File Full ID', "    Expect full_id to be #{expected_id}. It was.")
      number       += 10
    end

    STDERR.puts('    The Model file renumbered the Model Files successfully.')
  end

  test 'should get model files' do
    STDERR.puts('    Check to see that the Model file can get the Model Files.')
    assert_not_equals_nil(ModelFile.get_model_files(@project.id),
                          'Model Files',
                          '    Expect Model Files to not be nil. It was.')
    STDERR.puts('    The Model file returned Model Files successfully.')
  end

  test 'should duplicate file' do
    STDERR.puts('    Check to see that the Model file can duplicate a file.')

    folder = Document.get_or_create_folder('test', @project.id, @hardware_item.id)

    assert_equals('/var/folders/documents/test/test/test',
                  ModelFile.duplicate_file(folder, 'test', @model_file_001),
                  'File Path',
                  '    Expect path to be /var/folders/documents/test/test/test. It was.')
    STDERR.puts('    The Model file returned Model Files successfully.')
  end

  test 'should get columns' do
    STDERR.puts('    Check to see that the Model file can return the columns.')

    columns = @model_file_001.get_columns
    columns = columns[0..18] + columns[20..23]

    assert_equals([
                     808178995,
                     1,
                     "MF-001",
                     "Model File",
                     "/var/folders/model_files/patmos_engineering_services/Screen Shot 2020-03-31 at 2.15.15 PM.png",
                     "image/png",
                     "ATTACHMENT",
                     "Screen Shot 2020-03-31 at 2.15.15 PM.png",
                     "Screen Shot 2020-03-31 at 2.15.15 PM.png",
                     false,
                     false,
                     "nil",
                     "SYS-001",
                     "HLR-001",
                     "LLR-001",
                     "TC-001",
                     0,
                     "nil",
                     "1",
                     "test",
                     "Test",
                     "",
                     nil
                  ],
                  columns, 'Columns',
                  '    Expect columns to be [808178995, 1, "MF-001", "Model File", "/var/folders/model_files/patmos_engineering_services/Screen Shot 2020-03-31 at 2.15.15 PM.png", "image/png", "ATTACHMENT", "Screen Shot 2020-03-31 at 2.15.15 PM.png", "Screen Shot 2020-03-31 at 2.15.15 PM.png", false, false, "nil", "SYS-001", "HLR-001", "LLR-001", "TC-001", 0, "nil", "1", "test", "Test", "", nil]. It was.')
    STDERR.puts('    The Model file returned the columns successfully.')
  end

  test 'should generate CSV' do
    STDERR.puts('    Check to see that the Model file can generate CSV properly.')

    csv   = ModelFile.to_csv(@project.id)
    lines = csv.split("\n")

    assert_equals('id,model_id,full_id,description,file_path,file_type,url_type,url_link,url_description,soft_delete,derived,derived_justification,system_requirement_associations,high_level_requirement_associations,low_level_requirement_associations,test_case_associations,version,revision,draft_version,revision_date,organization,project_id,item_id,archive_id,created_at,updated_at,upload_date',
                  lines[0], 'Header',
                  '    Expect header to be id,model_id,full_id,description,file_path,file_type,url_type,url_link,url_description,soft_delete,derived,derived_justification,system_requirement_associations,high_level_requirement_associations,low_level_requirement_associations,test_case_associations,version,revision,draft_version,revision_date,organization,project_id,item_id,archive_id,created_at,updated_at,upload_date. It was.')
    assert_equals('808178995,1,MF-001,Model File,/var/folders/model_files/patmos_engineering_services/Screen Shot 2020-03-31 at 2.15.15 PM.png,image/png,ATTACHMENT,Screen Shot 2020-03-31 at 2.15.15 PM.png,Screen Shot 2020-03-31 at 2.15.15 PM.png,false,false,nil,SYS-001,HLR-001,LLR-001,TC-001,0,nil,1',
                  lines[1][0..280], 'First Record',
                  '    Expect first line to be 808178995,1,MF-001,Model File,... It was.')
    STDERR.puts('    The Model file generated CSV successfully.')
  end

  test 'should generate XLS' do
    STDERR.puts('    Check to see that the Model file can generate XLS properly.')

    assert_nothing_raised do
      xls = ModelFile.to_xls(@project.id)

      assert_not_equals_nil(xls, 'XLS Data', '    Expect XLS Data to not be nil. It was.')
    end

    STDERR.puts('    The Model file generated XLS successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the Model file can assign columns properly.')

    mf = ModelFile.new()

    assert(mf.assign_column('id', '1', @hardware_item.id))
    assert(mf.assign_column('project_id', 'Test', @hardware_item.id))
    assert_equals(@project.id, mf.project_id, 'Project ID',
                  "    Expect Project ID to be #{@project.id}. It was.")
    assert(mf.assign_column('item_id', @hardware_item.id.to_s, @hardware_item.id))
    assert_equals(@hardware_item.id, mf.item_id, 'Item ID',
                  "    Expect Item ID to be #{@hardware_item.id}. It was.")
    assert(mf.assign_column('model_id', @model_file_001.model_id.to_s,
                             @hardware_item.id))
    assert_equals(@model_file_001.model_id, mf.model_id, 'File ID',
                  "    Expect File ID to be #{@model_file_001.model_id}. It was.")
    assert(mf.assign_column('full_id', @model_file_001.full_id,
                             @hardware_item.id))
    assert_equals(@model_file_001.full_id, mf.full_id, 'Full ID',
                  "    Expect Full ID to be #{@model_file_001.full_id}. It was.")
    assert(mf.assign_column('description', @model_file_001.description,
                             @hardware_item.id))
    assert_equals(@model_file_001.description, mf.description, 'Description',
                  "    Expect Description to be #{@model_file_001.description}. It was.")
    assert(mf.assign_column('file_path', @model_file_001.file_path,
                             @hardware_item.id))
    assert_equals(@model_file_001.file_path, mf.file_path, 'File_path',
                  "    Expect File_path to be #{@model_file_001.file_path}. It was.")
    assert(mf.assign_column('file_type', @model_file_001.file_type,
                             @hardware_item.id))
    assert_equals(@model_file_001.file_type, mf.file_type, 'File_type',
                  "    Expect File_type to be #{@model_file_001.file_type}. It was.")
    assert(mf.assign_column('url_type', @model_file_001.url_type,
                             @hardware_item.id))
    assert_equals(@model_file_001.url_type, mf.url_type, 'Url_type',
                  "    Expect Url_type to be #{@model_file_001.url_type}. It was.")
    assert(mf.assign_column('url_link', @model_file_001.url_link,
                             @hardware_item.id))
    assert_equals(@model_file_001.url_link, mf.url_link, 'Url_link',
                  "    Expect Url_link to be #{@model_file_001.url_link}. It was.")
    assert(mf.assign_column('url_description', @model_file_001.url_description,
                             @hardware_item.id))
    assert_equals(@model_file_001.url_description, mf.url_description, 'Url_description',
                  "    Expect Url_description to be #{@model_file_001.url_description}. It was.")
    assert(mf.assign_column('soft_delete', 'true', @hardware_item.id))
    assert_equals(true, mf.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'true' to be true. It was.")
    assert(mf.assign_column('soft_delete', 'false', @hardware_item.id))
    assert_equals(false, mf.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'false' to be false. It was.")
    assert(mf.assign_column('soft_delete', 'yes', @hardware_item.id))
    assert_equals(true, mf.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'yes' to be true. It was.")
    assert(mf.assign_column('derived', 'true', @hardware_item.id))
    assert_equals(true, mf.derived, 'Derived',
                  "    Expect Derived from 'true' to be true. It was.")
    assert(mf.assign_column('derived', 'false', @hardware_item.id))
    assert_equals(false, mf.derived, 'Derived',
                  "    Expect Derived from 'false' to be false. It was.")
    assert(mf.assign_column('derived', 'yes', @hardware_item.id))
    assert_equals(true, mf.derived, 'Derived',
                  "    Expect Derived from 'yes' to be true. It was.")
    assert(mf.assign_column('derived_justification', @model_file_001.derived_justification,
                             @hardware_item.id))
    assert_equals(@model_file_001.derived_justification, mf.derived_justification, 'derived_justification',
                  "    Expect derived_justification to be #{@model_file_001.derived_justification}. It was.")
    assert(mf.assign_column('system_requirement_associations', 'SYS-001',
                             @hardware_item.id))
    assert_equals(@model_file_001.system_requirement_associations,
                  mf.system_requirement_associations,
                  'System Requirement Associations',
                  "    Expect System Requirement Associations to be #{@model_file_001.system_requirement_associations}. It was.")
    assert(mf.assign_column('high_level_requirement_associations', 'HLR-001',
                             @hardware_item.id))
    assert_equals(@model_file_001.high_level_requirement_associations,
                  mf.high_level_requirement_associations,
                  'High Level Requirement Associations',
                  "    Expect High Level Requirement Associations to be #{@model_file_001.high_level_requirement_associations}. It was.")
    assert(mf.assign_column('low_level_requirement_associations', 'LLR-001',
                             @hardware_item.id))
    assert_equals(@model_file_001.low_level_requirement_associations,
                  mf.low_level_requirement_associations,
                  'Low Level Requirement Associations',
                  "    Expect Low Level Requirement Associations to be #{@model_file_001.low_level_requirement_associations}. It was.")
    assert(mf.assign_column('test_case_associations', 'TC-001',
                             @hardware_item.id))
    assert_equals(@model_file_001.test_case_associations,
                  mf.test_case_associations,
                  'Test Case Associations',
                  "    Expect Test Case Associations to be #{@model_file_001.test_case_associations}. It was.")
    assert(mf.assign_column('version', @model_file_001.version.to_s,
                             @hardware_item.id))
    assert_equals(@model_file_001.version, mf.version, 'Version',
                  "    Expect Version to be #{@model_file_001.version}. It was.")
    assert(mf.assign_column('revision', @model_file_001.revision,
                             @hardware_item.id))
    assert_equals(@model_file_001.revision, mf.revision, 'Revision',
                  "    Expect Revision to be #{@model_file_001.revision}. It was.")
    assert(mf.assign_column('draft_version', @model_file_001.draft_version,
                             @hardware_item.id))
    assert_equals(@model_file_001.draft_version, mf.draft_version, 'Draft_version',
                  "    Expect Draft_version to be #{@model_file_001.draft_version}. It was.")
    assert(mf.assign_column('revision_date', @model_file_001.revision_date.to_s,
                             @hardware_item.id))
    assert_equals(@model_file_001.revision_date, mf.revision_date, 'Revision_date',
                  "    Expect Revision_date to be #{@model_file_001.revision_date}. It was.")
    assert(mf.assign_column('created_at', @model_file_001.created_at.to_s,
                             @hardware_item.id))
    assert(mf.assign_column('updated_at', @model_file_001.updated_at.to_s,
                             @hardware_item.id))
    assert(mf.assign_column('organization', @model_file_001.organization,
                             @hardware_item.id))
    assert(mf.assign_column('upload_date', @model_file_001.upload_date.to_s,
                             @hardware_item.id))
    assert_equals(@model_file_001.upload_date, mf.upload_date, 'Upload_date',
                  "    Expect Upload_date to be #{@model_file_001.upload_date}. It was.")
    assert(mf.assign_column('archive_revision', 'a', @hardware_item.id))
    assert(mf.assign_column('archive_version', '1.1', @hardware_item.id))
    STDERR.puts('    The Model file assigned the columns successfully.')
  end

  test 'should parse CSV string' do
    STDERR.puts('    Check to see that the Model file can parse CSV properly.')

    attributes = [
                    'description',
                    'file_path',
                    'file_type',
                    'url_type',
                    'url_description',
                    'url_link',
                    'soft_delete',
                    'derived',
                    'derived_justification',
                    'system_requirement_associations',
                    'high_level_requirement_associations',
                    'low_level_requirement_associations',
                    'test_case_associations',
                    'version',
                    'revision',
                    'draft_version',
                    'revision_date',
                    'organization',
                    'project_id',
                    'archive_id',
                    'upload_date'
                 ]
    csv        = ModelFile.to_csv(@project.id, nil)
    lines      = csv.gsub(/\n(\d+),/, "\r#{$1},").split("\r")

    assert_equals(:duplicate_model_file,
                  ModelFile.from_csv_string(lines[1],
                                            @project.id,
                                             nil,
                                             [ :check_duplicates ]),
                  'Model File Records',
                  '    Expect Duplicate Model File Records to error. They did.')

    line       = lines[1].gsub('HLR-001', 'HLR-002')

    assert_equals(:model_file_requirement_associations_changed,
                  ModelFile.from_csv_string(line,
                                            @project.id,
                                             nil,
                                             [ :check_associations ]),
                  'Model File Records',
                  '    Expect Changed Associations Records to error. They did.')

    line       = lines[1].gsub('1,MF-001', '3,MF-003')

    assert(ModelFile.from_csv_string(line, @project.id))

    mf        = ModelFile.find_by(full_id: 'MF-003')

    assert_equals(true, compare_records(@model_file_001, mf, attributes),
                  'Model File Records',
                  '    Expect Model File Records to match. They did.')
    STDERR.puts('    The Model file parsed CSV successfully.')
  end

  test 'should parse files' do
    STDERR.puts('    Check to see that the Model file can parse files properly.')
    assert_equals(:duplicate_model_file,
                  ModelFile.from_file('test/fixtures/files/Test-Model_Files.csv',
                                      @project.id,
                                      nil,
                                      [ :check_duplicates ]),
                  'Model File Records from Test-Model_Files.csv',
                  '    Expect Duplicate Model File Records to error. They did.')
    assert_equals(true,
                  ModelFile.from_file('test/fixtures/files/Test-Model_Files.csv',
                                      @project.id),
                  'Model File Records From Test-Model_Files.csv',
                  '    Expect Changed Model File Associations Records  from Test-Model_Files.csv to error. They did.')
    assert_equals(:duplicate_model_file,
                  ModelFile.from_file('test/fixtures/files/Test-Model_Files.xls',
                                      @project.id,
                                      nil,
                                      [ :check_duplicates ]),
                  'Model File Records from Test-Model_Files.csv',
                  '    Expect Duplicate Model File Records to error. They did.')
    assert_not_equals_nil(ModelFile.from_file('test/fixtures/files/Test-Model_Files.xls',
                                              @project.id),
                          'Model File Records From Test-Model_Files.csv',
                          '    Expect Changed Model File Associations Records  from Test-Model_Files.csv to error. They did.')
    assert_equals(:duplicate_model_file,
                  ModelFile.from_file('test/fixtures/files/Test-Model_Files.xlsx',
                                      @project.id,
                                      nil,
                                      [ :check_duplicates ]),
                  'Model File Records from Test-Model_Files.csv',
                  '    Expect Duplicate Model File Records to error. They did.')
    assert_not_equals_nil(ModelFile.from_file('test/fixtures/files/Test-Model_Files.xlsx',
                                              @project.id),
                          'Model File Records From Test-Model_Files.csv',
                          '    Expect Changed Model File Associations Records  from Test-Model_Files.csv to error. They did.')
    STDERR.puts('    The Model file parsed files successfully.')
  end
end

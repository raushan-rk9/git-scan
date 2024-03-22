require 'test_helper'

class TestProcedureTest < ActiveSupport::TestCase
  def compare_tps(x, y,
                   attributes = [
                                  'procedure_id',
                                  'full_id',
                                  'file_name',
                                  'url_type',
                                  'url_description',
                                  'url_link',
                                  'version',
                                  'organization',
                                  'item_id',
                                  'project_id',
                                  'archive_id',
                                  'test_case_associations',
                                  'description',
                                  'soft_delete',
                                  'document_id',
                                  'file_path',
                                  'content_type',
                                  'file_type',
                                  'revision',
                                  'draft_version'
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

  test 'test procedure record should be valid' do
    STDERR.puts('    Check to see that a Test Procedure Record with required fields filled in is valid.')
    assert_equals(true, @hardware_tp_001.valid?, 'Test Procedure Record', '    Expect Test Procedure Record to be valid. It was valid.')
    STDERR.puts('    The Test Procedure Record was valid.')
  end

  test 'procedure id shall be present for test procedure' do
    STDERR.puts('    Check to see that a Test Procedure Record without a Procedure ID is invalid.')

    @hardware_tp_001.procedure_id = nil

    assert_equals(false, @hardware_tp_001.valid?, 'Test Procedure Record', '    Expect Test Procedure without procedure_id not to be valid. It was not valid.')
    STDERR.puts('    The Test Procedure Record was invalid.')
  end

  test 'project id shall be present for test procedure' do
    STDERR.puts('    Check to see that a Test Procedure Record without a Project ID is invalid.')
    @hardware_tp_001.project_id = nil

    assert_equals(false, @hardware_tp_001.valid?, 'Test Procedure Record', '    Expect Test Procedure without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Test Procedure Record was invalid.')
  end

  test 'item id shall be present for test procedure' do
    STDERR.puts('    Check to see that a Test Procedure Record without an Item ID is invalid.')
    @hardware_tp_001.item_id = nil

    assert_equals(false, @hardware_tp_001.valid?, 'Test Procedure Record', '    Expect Test Procedure without item_id not to be valid. It was not valid.')
    STDERR.puts('    The Test Procedure Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Test Procedure' do
    STDERR.puts('    Check to see that a Test Procedure can be created.')

    test_procedure = TestProcedure.new({
                                          procedure_id:           @hardware_tp_001.procedure_id,
                                          full_id:                @hardware_tp_001.full_id,
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
                                        })

    assert_not_equals_nil(test_procedure.save, 'Test Procedure Record', '    Expect Test Procedure Record to be created. It was.')
    STDERR.puts('    A Test Procedure was successfully created.')
  end

  test 'should update Test Procedure' do
    STDERR.puts('    Check to see that a Test Procedure can be updated.')

    full_id                   = @hardware_tp_001.full_id.dup
    @hardware_tp_001.full_id += '_001'

    assert_not_equals_nil(@hardware_tp_001.save, 'Test Procedure Record', '    Expect Test Procedure Record to be updated. It was.')

    @hardware_tp_001.full_id  = full_id
    STDERR.puts('    A Test Procedure was successfully updated.')
  end

  test 'should delete Test Procedure' do
    STDERR.puts('    Check to see that a Test Procedure can be deleted.')
    assert(@hardware_tp_001.destroy)
    STDERR.puts('    A Test Procedure was successfully deleted.')
  end

  test 'should create Test Procedure with undo/redo' do
    STDERR.puts('    Check to see that a Test Procedure can be created, then undone and then redone.')

    test_procedure = TestProcedure.new({
                                          procedure_id:           @hardware_tp_001.procedure_id,
                                          full_id:                @hardware_tp_001.full_id,
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
                                        })
    data_change            = DataChange.save_or_destroy_with_undo_session(test_procedure, 'create')

    assert_not_equals_nil(data_change, 'Test Procedure Record', '    Expect Test Procedure Record to be created. It was.')

    assert_difference('TestProcedure.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('TestProcedure.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Test Procedure was successfully created, then undone and then redone.')
  end

  test 'should update Test Procedure with undo/redo' do
    STDERR.puts('    Check to see that a Test Procedure can be updated, then undone and then redone.')

    full_id                    = @hardware_tp_001.full_id.dup
    @hardware_tp_001.full_id += '_001'
    data_change                = DataChange.save_or_destroy_with_undo_session(@hardware_tp_001, 'update')
    @hardware_tp_001.full_id  = full_id

    assert_not_equals_nil(data_change, 'Test Procedure Record', '    Expect Test Procedure Record to be updated. It was')
    assert_not_equals_nil(TestProcedure.find_by(full_id: @hardware_tp_001.full_id + '_001', item_id: @hardware_item.id), 'Test Procedure Record', "    Expect Test Procedure Record's ID to be #{@hardware_tp_001.full_id + '_001'}. It was.")
    assert_equals(nil, TestProcedure.find_by(full_id: @hardware_tp_001.full_id, item_id: @hardware_item.id), 'Test Procedure Record', '    Expect original Test Procedure Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, TestProcedure.find_by(full_id: @hardware_tp_001.full_id + '_001', item_id: @hardware_item.id), 'Test Procedure Record', "    Expect updated Test Procedure's Record not to found. It was not found.")
    assert_not_equals_nil(TestProcedure.find_by(full_id: @hardware_tp_001.full_id, item_id: @hardware_item.id), 'Test Procedure Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(TestProcedure.find_by(full_id: @hardware_tp_001.full_id + '_001', item_id: @hardware_item.id), 'Test Procedure Record', "    Expect updated Test Procedure's Record to be found. It was found.")
    assert_equals(nil, TestProcedure.find_by(full_id: @hardware_tp_001.full_id, item_id: @hardware_item.id), 'Test Procedure Record', '    Expect Orginal Record not to be found. It was not found.')

    STDERR.puts('    A Test Procedure was successfully updated, then undone and then redone.')
  end

  test 'should delete Test Procedure with undo/redo' do
    STDERR.puts('    Check to see that a Test Procedure can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@hardware_tp_001, 'delete')

    assert_not_equals_nil(data_change, 'Test Procedure Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, TestProcedure.find_by(procedure_id: @hardware_tp_001.procedure_id, item_id: @hardware_item.id), 'Test Procedure Record', '    Verify that the Test Procedure Record was actually deleted. It was.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(TestProcedure.find_by(procedure_id: @hardware_tp_001.procedure_id, item_id: @hardware_item.id), 'Test Procedure Record', '    Verify that the Test Procedure Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, TestProcedure.find_by(procedure_id: @hardware_tp_001.procedure_id, item_id: @hardware_item.id), 'Test Procedure Record', '    Verify that the Test Procedure Record was deleted again after redo. It was.')

    STDERR.puts('    A Test Procedure was successfully deleted, then undone and then redone.')
  end

  test 'item_id_from_id should be correct' do
    STDERR.puts('    Check to see that the Test Procedure  returns a Item ID from an ID.')
    assert_equals(@hardware_tp_001.item_id,
                  TestProcedure.item_id_from_id(@hardware_tp_001.id),
                  'item_id_from_id',
                  "    Verify that item_id_from_id was #{@hardware_tp_001.item_id}. It was.")
    STDERR.puts('    The Test Procedure returned a proper Item ID from an ID successfully.')
  end

  test 'procedure_id_plus_filename_from_id should be correct' do
    STDERR.puts('    Check to see that the Test Procedure returns a proper Procedure ID with Filename from ID.')
    assert_equals('TP-001 - overpressure.py',
                  TestProcedure.procedure_id_plus_filename_from_id(@hardware_tp_001.id),
                  'procedure_id_plus_filename_from_id',
                  "    Verify that item_id_from_id was 'TP-001 - overpressure.py'. It was.")
    STDERR.puts('    The Test Procedure returned a proper Procedure ID with Filename from an ID successfully.')
  end

  test 'full_procedure_id should be correct' do
    STDERR.puts('    Check to see that the Test Procedure returns a proper Full Procedure ID from ID.')
    assert_equals('TP-001', @hardware_tp_001.full_procedure_id, 'Test Procedure Record', '    Expect full_procedure_id with full_id to be "TP-001". It was.')

    @hardware_tp_001.full_id = nil

    assert_equals('HARDWARE_ITEM-TP-1', @hardware_tp_001.full_procedure_id, 'Test Procedure Record', '    Expect full_procedure_id without full_id to be "HARDWARE_ITEM-TP-1". It was.')
    STDERR.puts('    The Test Procedure returned a proper Full Procedure ID from ID successfully.')
  end

  test 'procedure_id_plus_filename should be correct' do
    STDERR.puts('    Check to see that the Test Procedure returns a proper Procedure ID with Filename.')
    @hardware_tp_001.procedure_id_plus_filename

    assert_equals('TP-001 - overpressure.py', @hardware_tp_001.procedure_id_plus_filename, 'Test Procedure Record', '    Expect procedure_id_plus_filename with full_id to be "TP-001 - overpressure.py." It was.')

    @hardware_tp_001.full_id = nil

    assert_equals('HARDWARE_ITEM-TP-1 - overpressure.py', @hardware_tp_001.procedure_id_plus_filename, 'Test Procedure Record', '    Expect procedure_id_plus_filename without full_id to be "HARDWARE_ITEM-TP-1- overpressure.py." It was.')
    STDERR.puts('    The Test Procedure returned a proper Procedure ID with Filename successfully.')
  end

  test 'get_test_case should return the Test Case' do
    STDERR.puts('    Check to see that the Test Procedure returns a proper Test Case.')
    assert_not_equals_nil(@hardware_tp_001.get_test_case, 'Test Case Record', '    Expect get_high_level_requirement to get a High Level Requirement. It did.')
    STDERR.puts('    The Test Procedure returned a proper Test Case successfully.')
  end

  test 'get_root_path should return the Root Path' do
    STDERR.puts('    Check to see that a Test Procedure can return the root directory.')
    assert_equals('/var/folders/test_procedures/test', @hardware_tp_001.get_root_path, 'Test Procedure Record', '    Expect the return from get_root_path to be /var/folders/test_procedures/test." It was.')
    STDERR.puts('    The Test Procedure successfully returned the root directory.')
  end

  test 'get_file_path should return the File Path' do
    STDERR.puts('    Check to see that a Test Procedure can return the file path for a document.')
    assert_equals('/var/folders/test_procedures/test/overpressure.py', @hardware_tp_001.get_file_path, 'Test Procedure Record', '    Expect the return from get_file_path to be /var/folders/test_procedures/test/overpressure.py." It was.')
    STDERR.puts('    The Test Procedure successfully returned the file path for a document.')
  end

  test 'get_file_contents should return the file contents' do
    STDERR.puts('    Check to see that a Test Procedure can get the contents from a document.')

    file = @hardware_tp_001.get_file_contents

    assert_equals('upload_file', file.name, 'File Name', "    Expect the file.name to be 'upload_file'. It was.")
    assert_equals('overpressure.py', file.filename.to_s, 'Filename', "    Expect the file.filename to be 'overpressure.py'. It was.")
    assert_equals('text/x-python3', file.content_type, 'Filename', "    Expect the file.content_type to be 'text/x-python3'. It was.")
    assert_equals(22049, file.download.length, 'Filename', "    Expect the file.download.length to be 22049. It was.")
    STDERR.puts('    The Test Procedure successfully got the contents from a document.')
  end

  test 'store_file should store a file' do
    STDERR.puts('    Check to see that a Test Procedure can store a file.')

    tp       = TestProcedure.new()
    filename = tp.store_file(@file_data, true, true)

    assert_equals('/var/folders/test_procedures/test/flowchart-1.png', filename, 'Filename', "    Expect the filename to be '/var/folders/test_procedures/test/flowchart-1.png'. It was.")
    STDERR.puts('    The Test Procedure successfully stored a file.')
  end

  test 'replace_file should replace a file' do
    STDERR.puts('    Check to see that a Test Procedure can replace a file.')
    FileUtils.cp('test/fixtures/files/overpressure.py',
                 '/var/folders/test_procedures/test/overpressure.py')
    assert_not_equals_nil(@hardware_tp_001.replace_file(@file_data,
                                                        @project.id,
                                                         @hardware_item),
                          'Data Change Record',
                          '    Expect Data Change Record to not be nil. It was.')
    STDERR.puts('    The Test Procedure successfully replaced a file.')
  end

  test 'should rename prefix' do
    STDERR.puts('    Check to see that the Test Procedure can rename its prefix.')

    original_tps = TestProcedure.where(item_id: @hardware_item.id)
    original_tps = original_tps.to_a.sort { |x, y| x.full_id <=> y.full_id}

    TestProcedure.rename_prefix(@project.id, @hardware_item.id,
                                'TP', 'Test Procedure')

    renamed_tps  = TestProcedure.where(item_id: @hardware_item.id)
    renamed_tps  = renamed_tps.to_a.sort { |x, y| x.full_id <=> y.full_id}

    original_tps.each_with_index do |tp, index|
      expected_id = tp.full_id.sub('TP', 'Test Procedure')
      renamed_tp = renamed_tps[index]

      assert_equals(expected_id, renamed_tp.full_id, 'Test Procedure Full ID', "    Expect full_id to be #{expected_id}. It was.")
    end

    STDERR.puts('    The Test Procedure renamed its prefix successfully.')
  end

  test 'should renumber' do
    STDERR.puts('    Check to see that the Test Procedure can renumber the Test Procedures.')

    original_tps    = TestProcedure.where(item_id: @hardware_item.id)
    original_tps    = original_tps.to_a.sort { |x, y| x.full_id <=> y.full_id}

    TestProcedure.renumber(@hardware_item.id, 10, 10, 'Test Procedure')

    renumbered_tps  = TestProcedure.where(item_id: @hardware_item.id)
    renumbered_tps  = renumbered_tps.to_a.sort { |x, y| x.full_id <=> y.full_id}
    number          = 10

    original_tps.each_with_index do |tp, index|
      expected_id   = tp.full_id.sub('TP', 'Test Procedure').sub(/\-\d{3}/, sprintf('-%03d', number))
      renumbered_tp = renumbered_tps[index]

      assert_equals(expected_id, renumbered_tp.full_id, 'Test Procedure Full ID', "    Expect full_id to be #{expected_id}. It was.")
      number       += 10
    end

    STDERR.puts('    The Test Procedure renumbered the Test Procedures successfully.')
  end

  test 'should get columns' do
    STDERR.puts('    Check to see that the Test Procedure can return the columns.')

    columns = @hardware_tp_001.get_columns
    columns = columns[1..10] + columns[13..16]

    assert_equals([
                     1, "TP-001", "overpressure.py", "ATTACHMENT",
                     "overpressure.py", "overpressure.py", 0, "test",
                     "HARDWARE_ITEM", "Test", nil, "TC-001",
                     "Test pump over pressure.", nil
                  ],
                  columns, 'Columns',
                  '    Expect columns to be [1, "TP-001", "overpressure.py", "ATTACHMENT", "overpressure.py", "overpressure.py", 0, "test", "HARDWARE_ITEM", "Test", nil, "TC-001", "Test pump over pressure.", nil]. It was.')
    STDERR.puts('    The Test Procedure returned the columns successfully.')
  end

  test 'should generate CSV' do
    STDERR.puts('    Check to see that the Test Procedure can generate CSV properly.')

    csv   = TestProcedure.to_csv(@hardware_item.id)
    lines = csv.split("\n")

    assert_equals('id,procedure_id,full_id,file_name,url_type,url_description,url_link,version,organization,item_id,project_id,created_at,updated_at,archive_id,test_case_associations,description,soft_delete,document_id,file_path,content_type,file_type,revision,draft_version,revision_date,upload_date,archive_revision,archive_version',
                  lines[0], 'Header',
                  '    Expect header to be "id,procedure_id,full_id,file_name,url_type,url_description,url_link,version,organization,item_id,project_id,created_at,updated_at,archive_id,test_case_associations,description,soft_delete,document_id,file_path,content_type,file_type,revision,draft_version,revision_date,upload_date,archive_revision,archive_version". It was.')

    lines[1..-1].each do |line|
      assert_not_equals_nil((line =~ /^\d+,\d,TP\-\d{3},(over|under)pressure\.py,ATTACHMENT,(over|under)pressure\.py,(over|under)pressure\.py,0,test,HARDWARE_ITEM,Test,20.+,20.+,,TC-00\d,Test pump (over|under) pressure\.,,"",\/var\/folders\/test_procedures\/test\/(over|under)pressure\.py,text\/x\-python3,text\/x\-python3,"",0\.1,,.*$/),
                            '    Expect line to be /^\d+,\d,TP\-\d{3},(over|under)pressure\.py,ATTACHMENT,(over|under)pressure\.py,(over|under)pressure\.py,0,test,HARDWARE_ITEM,Test,20.+,20.+,,TC-00\d,Test pump (over|under) pressure\.,,"",\/var\/folders\/test_procedures\/test\/(over|under)pressure\.py,text\/x\-python3,text\/x\-python3,"",0\.1,,.*$$/. It was.')
    end

    STDERR.puts('    The Test Procedure generated CSV successfully.')
  end

  test 'should generate XLS' do
    STDERR.puts('    Check to see that the Test Procedure can generate XLS properly.')

    assert_nothing_raised do
      xls = TestProcedure.to_xls(@hardware_item.id)

      assert_not_equals_nil(xls, 'XLS Data', '    Expect XLS Data to not be nil. It was.')
    end

    STDERR.puts('    The Test Procedure generated XLS successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the Test Procedure can assign columns properly.')

    tp = TestProcedure.new()

    assert(tp.assign_column('id', '1', @hardware_item.id))
    assert(tp.assign_column('project_id', 'Test', @hardware_item.id))
    assert_equals(@project.id, tp.project_id, 'Project ID',
                  "    Expect Project ID to be #{@project.id}. It was.")
    assert(tp.assign_column('item_id', @hardware_item.id.to_s, @hardware_item.id))
    assert_equals(@hardware_item.id, tp.item_id, 'Item ID',
                  "    Expect Item ID to be #{@hardware_item.id}. It was.")
    assert(tp.assign_column('procedure_id', @hardware_tp_001.procedure_id.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.procedure_id, tp.procedure_id, 'Procedure ID',
                  "    Expect Procedure ID to be #{@hardware_tp_001.procedure_id}. It was.")
    assert(tp.assign_column('full_id', @hardware_tp_001.full_id,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.full_id, tp.full_id, 'Full ID',
                  "    Expect Full ID to be #{@hardware_tp_001.full_id}. It was.")
    assert(tp.assign_column('file_name', @hardware_tp_001.file_name,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.file_name, tp.file_name, 'file_name',
                  "    Expect file_name to be #{@hardware_tp_001.file_name}. It was.")
    assert(tp.assign_column('version', @hardware_tp_001.version.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.version, tp.version, 'Version',
                  "    Expect Version to be #{@hardware_tp_001.version}. It was.")
    assert(tp.assign_column('url_type', @hardware_tp_001.url_type,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.url_type, tp.url_type, 'Url_type',
                  "    Expect Url_type to be #{@hardware_tp_001.url_type}. It was.")
    assert(tp.assign_column('url_link', @hardware_tp_001.url_link,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.url_link, tp.url_link, 'Url_link',
                  "    Expect Url_link to be #{@hardware_tp_001.url_link}. It was.")
    assert(tp.assign_column('url_description', @hardware_tp_001.url_description,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.url_description, tp.url_description, 'Url_description',
                  "    Expect Url_description to be #{@hardware_tp_001.url_description}. It was.")
    assert(tp.assign_column('test_case_associations', 'TC-001',
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.test_case_associations,
                  tp.test_case_associations,
                  'Test Case ID',
                  "    Expect Test Case ID to be #{@hardware_tp_001.test_case_associations}. It was.")
    assert(tp.assign_column('document_id', 'PHAC', @hardware_item.id))
    assert_equals(Document.find_by(docid: 'PHAC').try(:id),
                  tp.document_id,
                  'Document ID',
                  "    Expect Document ID to be #{Document.find_by(docid: 'PHAC').try(:id)}. It was.")
    assert(tp.assign_column('created_at', @hardware_tp_001.created_at.to_s,
                             @hardware_item.id))
    assert(tp.assign_column('updated_at', @hardware_tp_001.updated_at.to_s,
                             @hardware_item.id))
    assert(tp.assign_column('organization', @hardware_tp_001.organization,
                             @hardware_item.id))
    assert(tp.assign_column('soft_delete', 'true', @hardware_item.id))
    assert_equals(true, tp.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'true' to be true. It was.")
    assert(tp.assign_column('soft_delete', 'false', @hardware_item.id))
    assert_equals(false, tp.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'false' to be false. It was.")
    assert(tp.assign_column('soft_delete', 'yes', @hardware_item.id))
    assert_equals(true, tp.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'yes' to be true. It was.")
    assert(tp.assign_column('description', @hardware_tp_001.description,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.description, tp.description, 'Description',
                  "    Expect Description to be #{@hardware_tp_001.description}. It was.")
    assert(tp.assign_column('file_path', @hardware_tp_001.file_path,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.file_path, tp.file_path, 'File_path',
                  "    Expect File_path to be #{@hardware_tp_001.file_path}. It was.")
    assert(tp.assign_column('content_type', @hardware_tp_001.content_type,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.content_type, tp.content_type, 'Content_type',
                  "    Expect Content_type to be #{@hardware_tp_001.content_type}. It was.")
    assert(tp.assign_column('file_type', @hardware_tp_001.file_type,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.file_type, tp.file_type, 'File_type',
                  "    Expect File_type to be #{@hardware_tp_001.file_type}. It was.")
    assert(tp.assign_column('revision', @hardware_tp_001.revision,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.revision, tp.revision, 'Revision',
                  "    Expect Revision to be #{@hardware_tp_001.revision}. It was.")
    assert(tp.assign_column('draft_version', @hardware_tp_001.draft_version,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.draft_version, tp.draft_version, 'Draft_version',
                  "    Expect Draft_version to be #{@hardware_tp_001.draft_version}. It was.")
    assert(tp.assign_column('revision_date', @hardware_tp_001.revision_date.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.revision_date, tp.revision_date, 'Revision_date',
                  "    Expect Revision_date to be #{@hardware_tp_001.revision_date}. It was.")
    assert(tp.assign_column('upload_date', @hardware_tp_001.upload_date.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_tp_001.upload_date, tp.upload_date, 'Upload_date',
                  "    Expect Upload_date to be #{@hardware_tp_001.upload_date}. It was.")
    assert(tp.assign_column('archive_revision', 'a', @hardware_item.id))
    assert(tp.assign_column('archive_version', '1.1', @hardware_item.id))
    STDERR.puts('    The Test Procedure assigned the columns successfully.')
  end

  test 'should parse CSV string' do
    STDERR.puts('    Check to see that the Test Procedure can parse CSV properly.')

    attributes = [
                   'file_name',
                   'url_type',
                   'url_description',
                   'url_link',
                   'version',
                   'organization',
                   'item_id',
                   'project_id',
                   'archive_id',
                   'test_case_associations',
                   'description',
                   'soft_delete',
                   'document_id',
                   'file_path',
                   'content_type',
                   'file_type',
                   'revision',
                   'draft_version'
                 ]
    csv        = TestProcedure.to_csv(@hardware_item.id)
    lines      = csv.split("\n")

    assert_equals(:duplicate_test_procedure,
                  TestProcedure.from_csv_string(lines[1],
                                           @hardware_item,
                                           [ :check_duplicates ]),
                  'Test Procedure Records',
                  '    Expect Duplicate Test Procedure Records to error. They did.')

    line       = lines[1].gsub('TC-001', 'TC-002')

    assert_equals(:test_case_associations_changed,
                  TestProcedure.from_csv_string(line,
                                                @hardware_item,
                                                [ :check_associations ]),
                  'Test Procedure Records',
                  '    Expect Changed Associations Records to error. They did.')

    line       = lines[1].gsub('1,TP-001', '3,TP-003')

    assert(TestProcedure.from_csv_string(line, @hardware_item))

    tp        = TestProcedure.find_by(full_id: 'TP-003')

    assert_equals(true, compare_tps(@hardware_tp_001, tp, attributes),
                  'Test Procedure Records',
                  '    Expect Test Procedure Records to match. They did.')
    STDERR.puts('    The Test Procedure parsed CSV successfully.')
  end

  test 'should parse files' do
    STDERR.puts('    Check to see that the Test Procedure can parse files properly.')
    assert_equals(:duplicate_test_procedure,
                  TestProcedure.from_file('test/fixtures/files/Hardware Item-Test_Procedures.csv',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Test Procedure Records from Hardware Item-Test_procedures.csv',
                  '    Expect Duplicate Test Procedure Records to error. They did.')
    assert_equals(true,
                  TestProcedure.from_file('test/fixtures/files/Hardware Item-Test_Procedures.csv',
                                                 @hardware_item),
                  'Test Procedure Records From Hardware Item-Test_procedures.csv',
                  '    Expect Changed Test Procedure Associations Records  from Hardware Item-Test_procedures.csv to error. They did.')
    assert_equals(:duplicate_test_procedure,
                  TestProcedure.from_file('test/fixtures/files/Hardware Item-Test_Procedures.xls',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Test Procedure Records from Hardware Item-Test_procedures.csv',
                  '    Expect Duplicate Test Procedure Records to error. They did.')
    assert_equals(true,
                  TestProcedure.from_file('test/fixtures/files/Hardware Item-Test_Procedures.xls',
                                                 @hardware_item),
                  'Test Procedure Records From Hardware Item-Test_procedures.csv',
                  '    Expect Changed Test Procedure Associations Records  from Hardware Item-Test_procedures.csv to error. They did.')
    assert_equals(:duplicate_test_procedure,
                  TestProcedure.from_file('test/fixtures/files/Hardware Item-Test_Procedures.xlsx',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Test Procedure Records from Hardware Item-Test_procedures.csv',
                  '    Expect Duplicate Test Procedure Records to error. They did.')
    assert_equals(true,
                  TestProcedure.from_file('test/fixtures/files/Hardware Item-Test_Procedures.xlsx',
                                                 @hardware_item),
                  'Test Procedure Records From Hardware Item-Test_procedures.csv',
                  '    Expect Changed Test Procedure Associations Records  from Hardware Item-Test_procedures.csv to error. They did.')
    STDERR.puts('    The Test Procedure parsed files successfully.')
  end
end

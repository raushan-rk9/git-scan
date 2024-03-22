require 'test_helper'

class TestCaseTest < ActiveSupport::TestCase
  def compare_tcs(x, y,
                   attributes = [
                                  'caseid',
                                  'full_id',
                                  'description',
                                  'procedure',
                                  'category',
                                  'robustness',
                                  'derived',
                                  'testmethod',
                                  'version',
                                  'item_id',
                                  'project_id',
                                  'high_level_requirement_associations',
                                  'derived_justification',
                                  'organization',
                                  'archive_id',
                                  'low_level_requirement_associations',
                                  'soft_delete',
                                  'document_id',
                                  'model_file_id'
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

      break unless result
    end

    return result
  end

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

  test 'test case record should be valid' do
    STDERR.puts('    Check to see that a Test Case Record with required fields filled in is valid.')
    assert_equals(true, @hardware_tc_001.valid?, 'Test Case Record', '    Expect Test Case Record to be valid. It was valid.')
    STDERR.puts('    The Test Case Record was valid.')
  end

  test 'case id shall be present for test case' do
    STDERR.puts('    Check to see that a Test Case Record without a Case ID is invalid.')

    @hardware_tc_001.caseid = nil

    assert_equals(false, @hardware_tc_001.valid?, 'Test Case Record', '    Expect Test Case without caseid not to be valid. It was not valid.')
    STDERR.puts('    The Test Case Record was invalid.')
  end

  test 'project id shall be present for test case' do
    STDERR.puts('    Check to see that a Test Case Record without a Project ID is invalid.')
    @hardware_tc_001.project_id = nil

    assert_equals(false, @hardware_tc_001.valid?, 'Test Case Record', '    Expect Test Case without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Test Case Record was invalid.')
  end

  test 'item id shall be present for test case' do
    STDERR.puts('    Check to see that a Test Case Record without an Item ID is invalid.')
    @hardware_tc_001.item_id = nil

    assert_equals(false, @hardware_tc_001.valid?, 'Test Case Record', '    Expect Test Case without item_id not to be valid. It was not valid.')
    STDERR.puts('    The Test Case Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Test Case' do
    STDERR.puts('    Check to see that a Test Case can be created.')

    test_case = TestCase.new({
                                caseid:                              @hardware_tc_001.caseid,
                                full_id:                             @hardware_tc_001.full_id,
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
                              })

    assert_not_equals_nil(test_case.save, 'Test Case Record', '    Expect Test Case Record to be created. It was.')
    STDERR.puts('    A Test Case was successfully created.')
  end

  test 'should update Test Case' do
    STDERR.puts('    Check to see that a Test Case can be updated.')

    full_id                    = @hardware_tc_001.full_id.dup
    @hardware_tc_001.full_id += '_001'

    assert_not_equals_nil(@hardware_tc_001.save, 'Test Case Record', '    Expect Test Case Record to be updated. It was.')

    @hardware_tc_001.full_id  = full_id
    STDERR.puts('    A Test Case was successfully updated.')
  end

  test 'should delete Test Case' do
    STDERR.puts('    Check to see that a Test Case can be deleted.')
    assert(@hardware_tc_001.destroy)
    STDERR.puts('    A Test Case was successfully deleted.')
  end

  test 'should create Test Case with undo/redo' do
    STDERR.puts('    Check to see that a Test Case can be created, then undone and then redone.')

    test_case = TestCase.new({
                                caseid:                              @hardware_tc_001.caseid,
                                full_id:                             @hardware_tc_001.full_id,
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
                              })
    data_change            = DataChange.save_or_destroy_with_undo_session(test_case, 'create')

    assert_not_equals_nil(data_change, 'Test Case Record', '    Expect Test Case Record to be created. It was.')

    assert_difference('TestCase.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('TestCase.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Test Case was successfully created, then undone and then redone.')
  end

  test 'should update Test Case with undo/redo' do
    STDERR.puts('    Check to see that a Test Case can be updated, then undone and then redone.')

    full_id                    = @hardware_tc_001.full_id.dup
    @hardware_tc_001.full_id += '_001'
    data_change                = DataChange.save_or_destroy_with_undo_session(@hardware_tc_001, 'update')
    @hardware_tc_001.full_id  = full_id

    assert_not_equals_nil(data_change, 'Test Case Record', '    Expect Test Case Record to be updated. It was')
    assert_not_equals_nil(TestCase.find_by(full_id: @hardware_tc_001.full_id + '_001', item_id: @hardware_item.id), 'Test Case Record', "    Expect Test Case Record's ID to be #{@hardware_tc_001.full_id + '_001'}. It was.")
    assert_equals(nil, TestCase.find_by(full_id: @hardware_tc_001.full_id, item_id: @hardware_item.id), 'Test Case Record', '    Expect original Test Case Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, TestCase.find_by(full_id: @hardware_tc_001.full_id + '_001', item_id: @hardware_item.id), 'Test Case Record', "    Expect updated Test Case's Record not to found. It was not found.")
    assert_not_equals_nil(TestCase.find_by(full_id: @hardware_tc_001.full_id, item_id: @hardware_item.id), 'Test Case Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(TestCase.find_by(full_id: @hardware_tc_001.full_id + '_001', item_id: @hardware_item.id), 'Test Case Record', "    Expect updated Test Case's Record to be found. It was found.")
    assert_equals(nil, TestCase.find_by(full_id: @hardware_tc_001.full_id, item_id: @hardware_item.id), 'Test Case Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Test Case was successfully updated, then undone and then redone.')
  end

  test 'should delete Test Case with undo/redo' do
    STDERR.puts('    Check to see that a Test Case can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@hardware_tc_001, 'delete')

    assert_not_equals_nil(data_change, 'Test Case Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, TestCase.find_by(caseid: @hardware_tc_001.caseid, item_id: @hardware_item.id), 'Test Case Record', '    Verify that the Test Case Record was actually deleted. It was.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(TestCase.find_by(caseid: @hardware_tc_001.caseid, item_id: @hardware_item.id), 'Test Case Record', '    Verify that the Test Case Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, TestCase.find_by(caseid: @hardware_tc_001.caseid, item_id: @hardware_item.id), 'Test Case Record', '    Verify that the Test Case Record was deleted again after redo. It was.')
    STDERR.puts('    A Test Case was successfully deleted, then undone and then redone.')
  end

  test 'fullcaseid should be correct' do
    STDERR.puts('    Check to see that the Test Case returns a proper Full ID.')

    @hardware_tc_001.fullcaseid

    assert_equals('TC-001', @hardware_tc_001.fullcaseid, 'Test Case Record', '    Expect fullcaseid with full_id to be "TC-001". It was.')

    @hardware_tc_001.full_id = nil

    assert_equals('HARDWARE_ITEM-TC-1', @hardware_tc_001.fullcaseid, 'Test Case Record', '    Expect fullcaseid without full_id to be "HARDWARE_ITEM-TC-1". It was.')
    STDERR.puts('    The Test Case returned a proper Full ID successfully.')
  end

  test 'caseidplusdescription should be correct' do
    STDERR.puts('    Check to see that the Test Case returns a proper Case ID with Description.')
    @hardware_tc_001.caseidplusdescription

    assert_equals('TC-001 - Test pump over pressure.', @hardware_tc_001.caseidplusdescription, 'Test Case Record', '    Expect caseidplusdescription with full_id to be "TC-001 - Test pump over pressure." It was.')

    @hardware_tc_001.full_id = nil

    assert_equals('HARDWARE_ITEM-TC-1 - Test pump over pressure.', @hardware_tc_001.caseidplusdescription, 'Test Case Record', '    Expect caseidplusdescription without full_id to be "HARDWARE_ITEM-TC-1- Test pump over pressure." It was.')
    STDERR.puts('    The Test Case returned a proper Case ID with Description successfully.')
  end

  test 'get_high_level_requirement should return the High Level Requirement' do
    STDERR.puts('    Check to see that the Test Case can return an associated High-Level Requirement.')
    assert_not_equals_nil(@hardware_tc_001.get_high_level_requirement, 'High Level Requirement Record', '    Expect get_high_level_requirement to get a High Level Requirement. It did.')
    STDERR.puts('    The Test Case returned  an associated High-Level Requirement successfully.')
  end

  test 'get_low_level_requirement should return the Low Level Requirement' do
    STDERR.puts('    Check to see that the Test Case can return an associated Low-Level Requirement.')
    assert_not_equals_nil(@hardware_tc_001.get_low_level_requirement, 'Low Level Requirement Record', '    Expect get_low_level_requirement to get a Low Level Requirement. It did.')
    STDERR.puts('    The Test Case returned  an associated Low-Level Requirement successfully.')
  end

  test 'get_system_requirement should return the System Requirement' do
    STDERR.puts('    Check to see that the Test Case can return an associated System Requirement.')
    assert_not_equals_nil(@hardware_tc_001.get_system_requirement, 'System Requirement Record', '    Expect get_system_requirement to get a System Requirement. It did.')
    STDERR.puts('    The Test Case returned  an associated System Requirement successfully.')
  end

  test 'should add model' do
    STDERR.puts('    Check to see that the Test Case can add a model file.')
    model_file            = ModelFile.find(@hardware_tc_001.model_file_id)
    model_file.project_id = @hardware_tc_001.project_id
    model_file.item_id    = @hardware_tc_001.item_id

    model_file.save!
    assert_not_equals_nil(@hardware_tc_001.add_model_document(@file_data, nil), 'Test Case Record', '    Expect add_model_document to add a model document to a Test Case. It did.')
    STDERR.puts('    The Test Case added a model file successfully.')
  end

  test 'should rename prefix' do
    STDERR.puts('    Check to see that the Test Case can rename its prefix.')
    original_tcs = TestCase.where(item_id: @hardware_item.id)
    original_tcs = original_tcs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    TestCase.rename_prefix(@project.id, @hardware_item.id,
                                       'TC', 'Test Case')

    renamed_tcs  = TestCase.where(item_id: @hardware_item.id)
    renamed_tcs  = renamed_tcs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    original_tcs.each_with_index do |tc, index|
      expected_id = tc.full_id.sub('TC', 'Test Case')
      renamed_tc = renamed_tcs[index]

      assert_equals(expected_id, renamed_tc.full_id, 'Test Case Full ID', "    Expect full_id to be #{expected_id}. It was.")
    end

    STDERR.puts('    The Test Case renamed its prefix successfully.')
  end

  test 'should renumber' do
    STDERR.puts('    Check to see that the Test Case can renumber the Source Codes.')
    original_tcs = TestCase.where(item_id: @hardware_item.id)
    original_tcs = original_tcs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    TestCase.renumber(@hardware_item.id, 10, 10,
                                  'Test Case')

    renumbered_tcs = TestCase.where(item_id: @hardware_item.id)
    renumbered_tcs = renumbered_tcs.to_a.sort { |x, y| x.full_id <=> y.full_id}
    number          = 10

    original_tcs.each_with_index do |tc, index|
      expected_id    = tc.full_id.sub('TC', 'Test Case').sub(/\-\d{3}/, sprintf('-%03d', number))
      renumbered_tc = renumbered_tcs[index]

      assert_equals(expected_id, renumbered_tc.full_id, 'Test Case Full ID', "    Expect full_id to be #{expected_id}. It was.")
      number        += 10
    end

    STDERR.puts('    The Test Case renumbered the Source Codes successfully.')
  end

  test 'should get columns' do
    STDERR.puts('    Check to see that the Test Case can return the columns.')

    columns = @hardware_tc_001.get_columns
    columns = columns[1..14] + columns[17..21]

    assert_equals([
                    1, "TC-001", "Test pump over pressure.",
                    "Expected Results: Pressure over 4700 psia reports overpressure.",
                    "Safety", nil, nil, nil, "---\n- Test", 0, "HARDWARE_ITEM",
                    "Test", "HLR-001", "LLR-001", "test", nil, nil, "",
                    "MF-001"
                  ],
                  columns, 'Columns',
                  '    Expect columns to be [1, "TC-001", "Test pump over pressure.", "Expected Results: Pressure over 4700 psia reports overpressure.", "Safety", nil, nil, nil, "---\n- Test", 0, "HARDWARE_ITEM", "Test", "HLR-001", "LLR-001", "test", nil, nil, "", "MF-001"]. It was.')
    STDERR.puts('    The Test Case returned the columns successfully.')
  end

  test 'should generate CSV' do
    STDERR.puts('    Check to see that the Test Case can generate CSV properly.')

    csv   = TestCase.to_csv(@hardware_item.id).gsub("---\n- Test", "--- Test")
    lines = csv.split("\n")

    assert_equals('id,caseid,full_id,description,procedure,category,robustness,derived,derived_justification,testmethod,version,item_id,project_id,high_level_requirement_associations,low_level_requirement_associations,created_at,updated_at,organization,archive_id,soft_delete,document_id,model_file_id,archive_revision,archive_version',
                  lines[0], 'Header',
                  '    Expect header to be "id,caseid,full_id,description,procedure,category,robustness,derived,derived_justification,testmethod,version,item_id,project_id,high_level_requirement_associations,low_level_requirement_associations,created_at,updated_at,organization,archive_id,soft_delete,document_id,model_file_id,archive_revision,archive_version". It was.')

    lines[1..-1].each do |line|
      assert_not_equals_nil((line =~ /^\d+,\d,TC-\d{3},.+$/),
                            '    Expect line to be /^\d+,\d,TC-\d{3},.+$/. It was.')
    end

    STDERR.puts('    The Test Case generated CSV successfully.')
  end

  test 'should generate XLS' do
    STDERR.puts('    Check to see that the Test Case can generate XLS properly.')

    assert_nothing_raised do
      xls = TestCase.to_xls(@hardware_item.id)

      assert_not_equals_nil(xls, 'XLS Data', '    Expect XLS Data to not be nil. It was.')
    end

    STDERR.puts('    The Test Case generated XLS successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the Test Case can assign columns properly.')

    tc = TestCase.new()

    assert(tc.assign_column('id', '1', @hardware_item.id))
    assert(tc.assign_column('project_id', 'Test', @hardware_item.id))
    assert_equals(@project.id, tc.project_id, 'Project ID',
                  "    Expect Project ID to be #{@project.id}. It was.")
    assert(tc.assign_column('item_id', 'HARDWARE_ITEM', @hardware_item.id))
    assert_equals(@hardware_item.id, tc.item_id, 'Item ID',
                  "    Expect Item ID to be #{@hardware_item.id}. It was.")
    assert(tc.assign_column('caseid', @hardware_tc_001.caseid.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.caseid, tc.caseid, 'Case ID',
                  "    Expect Case ID to be #{@hardware_tc_001.caseid}. It was.")
    assert(tc.assign_column('full_id', @hardware_tc_001.full_id,
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.full_id, tc.full_id, 'Full ID',
                  "    Expect Full ID to be #{@hardware_tc_001.full_id}. It was.")
    assert(tc.assign_column('description', @hardware_tc_001.description,
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.description, tc.description, 'Description',
                  "    Expect Description to be #{@hardware_tc_001.description}. It was.")
    assert(tc.assign_column('procedure', @hardware_tc_001.procedure,
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.procedure, tc.procedure, 'Procedure',
                  "    Expect Procedure to be #{@hardware_tc_001.procedure}. It was.")
    assert(tc.assign_column('category', @hardware_tc_001.category,
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.category, tc.category, 'Category',
                  "    Expect Category to be #{@hardware_tc_001.category}. It was.")
    assert(tc.assign_column('robustness', 'true', @hardware_item.id))
    assert_equals(true, tc.robustness, 'Robustness',
                  "    Expect Robustness from 'true' to be true. It was.")
    assert(tc.assign_column('robustness', 'false', @hardware_item.id))
    assert_equals(false, tc.robustness, 'Robustness',
                  "    Expect Robustness from 'false' to be false. It was.")
    assert(tc.assign_column('robustness', 'yes', @hardware_item.id))
    assert_equals(true, tc.robustness, 'Robustness',
                  "    Expect Robustness from 'yes' to be true. It was.")
    assert(tc.assign_column('derived', 'true', @hardware_item.id))
    assert_equals(true, tc.derived, 'Derived',
                  "    Expect Derived from 'true' to be true. It was.")
    assert(tc.assign_column('derived', 'false', @hardware_item.id))
    assert_equals(false, tc.derived, 'Derived',
                  "    Expect Derived from 'false' to be false. It was.")
    assert(tc.assign_column('derived', 'yes', @hardware_item.id))
    assert_equals(true, tc.derived, 'Derived',
                  "    Expect Derived from 'yes' to be true. It was.")
    assert(tc.assign_column('derived_justification', 'Because', @hardware_item.id))
    assert_equals('Because', tc.derived_justification, 'Derived Justification',
                  "    Expect Derived Justification to be 'Because'. It was.")
    assert(tc.assign_column('testmethod',
                             @hardware_tc_001.testmethod,
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.testmethod, tc.testmethod, 'Test Method',
                  "    Expect Test Method to be #{@hardware_tc_001.testmethod}. It was.")
    assert(tc.assign_column('version', @hardware_tc_001.version.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.version, tc.version, 'Version',
                  "    Expect Version to be #{@hardware_tc_001.version}. It was.")
    assert(tc.assign_column('high_level_requirement_associations', 'HLR-001',
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.high_level_requirement_associations,
                  tc.high_level_requirement_associations,
                  'High Level Requirement ID',
                  "    Expect High Level Requirement ID to be #{@hardware_tc_001.high_level_requirement_associations}. It was.")
    assert(tc.assign_column('low_level_requirement_associations', 'LLR-001',
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.low_level_requirement_associations,
                  tc.low_level_requirement_associations,
                  'Low Level Requirement ID',
                  "    Expect Low Level Requirement ID to be #{@hardware_tc_001.low_level_requirement_associations}. It was.")
    assert(tc.assign_column('document_id', 'PHAC', @hardware_item.id))
    assert_equals(Document.find_by(docid: 'PHAC').try(:id),
                  tc.document_id,
                  'Document ID',
                  "    Expect Document ID to be #{Document.find_by(docid: 'PHAC').try(:id)}. It was.")
    assert(tc.assign_column('model_file_id', 'MF-001',
                             @hardware_item.id))
    assert_equals(@hardware_tc_001.model_file_id, tc.model_file_id,
                  'Model File ID',
                  "    Expect Model File ID to be #{@hardware_tc_001.model_file_id}. It was.")
    assert(tc.assign_column('created_at', @hardware_tc_001.created_at.to_s,
                             @hardware_item.id))
    assert(tc.assign_column('updated_at', @hardware_tc_001.updated_at.to_s,
                             @hardware_item.id))
    assert(tc.assign_column('organization', @hardware_tc_001.organization,
                             @hardware_item.id))
    assert(tc.assign_column('soft_delete', 'true', @hardware_item.id))
    assert_equals(true, tc.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'true' to be true. It was.")
    assert(tc.assign_column('soft_delete', 'false', @hardware_item.id))
    assert_equals(false, tc.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'false' to be false. It was.")
    assert(tc.assign_column('soft_delete', 'yes', @hardware_item.id))
    assert_equals(true, tc.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'yes' to be true. It was.")
    assert(tc.assign_column('archive_revision', 'a', @hardware_item.id))
    assert(tc.assign_column('archive_version', '1.1', @hardware_item.id))
    STDERR.puts('    The Test Case assigned the columns successfully.')
  end

  test 'should parse CSV string' do
    STDERR.puts('    Check to see that the Test Case can parse CSV properly.')

    attributes = [
                   'description',
                   'procedure',
                   'category',
                   'robustness',
                   'derived',
                   'version',
                   'item_id',
                   'project_id',
                   'high_level_requirement_associations',
                   'derived_justification',
                   'organization',
                   'archive_id',
                   'low_level_requirement_associations',
                   'soft_delete',
                   'document_id',
                   'model_file_id'
                 ]
    csv        = TestCase.to_csv(@hardware_item.id).gsub("---\n- Test", "--- Test")
    lines      = csv.split("\n")

    assert_equals(:duplicate_test_case,
                  TestCase.from_csv_string(lines[1],
                                           @hardware_item,
                                           [ :check_duplicates ]),
                  'Test Case Records',
                  '    Expect Duplicate Test Case Records to error. They did.')

    line       = lines[1].gsub('HLR-001', 'HLR-002')

    assert_equals(:high_level_requirement_associations_changed,
                  TestCase.from_csv_string(line,
                                           @hardware_item,
                                           [ :check_associations ]),
                  'Test Case Records',
                  '    Expect Changed Associations Records to error. They did.')

    line       = lines[1].gsub('1,TC-001', '4,TC-004')

    assert(TestCase.from_csv_string(line, @hardware_item))

    tc        = TestCase.find_by(full_id: 'TC-004')

    assert_equals(true, compare_tcs(@hardware_tc_001, tc, attributes),
                  'Test Case Records',
                  '    Expect Test Case Records to match. They did.')
    STDERR.puts('    The Test Case parsed CSV successfully.')
  end

  test 'should parse files' do
    STDERR.puts('    Check to see that the Test Case can parse Files properly.')
    assert_equals(:duplicate_test_case,
                  TestCase.from_file('test/fixtures/files/Hardware Item-Test_Cases.csv',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Test Case Records from Hardware Item-Test_cases.csv',
                  '    Expect Duplicate Test Case Records to error. They did.')
    assert_equals(true,
                  TestCase.from_file('test/fixtures/files/Hardware Item-Test_Cases.csv',
                                                 @hardware_item),
                  'Test Case Records From Hardware Item-Test_cases.csv',
                  '    Expect Changed Test Case Associations Records  from Hardware Item-Test_cases.csv to error. They did.')
    assert_equals(:duplicate_test_case,
                  TestCase.from_file('test/fixtures/files/Hardware Item-Test_Cases.xls',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Test Case Records from Hardware Item-Test_cases.csv',
                  '    Expect Duplicate Test Case Records to error. They did.')
    assert_equals(true,
                  TestCase.from_file('test/fixtures/files/Hardware Item-Test_Cases.xls',
                                                 @hardware_item),
                  'Test Case Records From Hardware Item-Test_cases.csv',
                  '    Expect Changed Test Case Associations Records  from Hardware Item-Test_cases.csv to error. They did.')
    assert_equals(:duplicate_test_case,
                  TestCase.from_file('test/fixtures/files/Hardware Item-Test_Cases.xlsx',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Test Case Records from Hardware Item-Test_cases.csv',
                  '    Expect Duplicate Test Case Records to error. They did.')
    assert_equals(true,
                  TestCase.from_file('test/fixtures/files/Hardware Item-Test_Cases.xlsx',
                                                 @hardware_item),
                  'Test Case Records From Hardware Item-Test_cases.csv',
                  '    Expect Changed Test Case Associations Records  from Hardware Item-Test_cases.csv to error. They did.')
    STDERR.puts('    The Test Case parsed Files successfully.')
  end
end

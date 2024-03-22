require 'test_helper'

class LowLevelRequirementTest < ActiveSupport::TestCase
  def compare_llrs(x, y,
                   attributes = [
                                  'reqid',
                                  'full_id',
                                  'description',
                                  'category',
                                  'verification_method',
                                  'safety',
                                  'derived',
                                  'version',
                                  'item_id',
                                  'project_id',
                                  'derived_justification',
                                  'organization',
                                  'archive_id',
                                  'high_level_requirement_associations',
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
    @project          = Project.find_by(identifier: 'TEST')
    @hardware_item    = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item    = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_llr_001 = LowLevelRequirement.find_by(item_id: @hardware_item.id,
                                                     full_id: 'LLR-001')
    @hardware_llr_002 = LowLevelRequirement.find_by(item_id: @hardware_item.id,
                                                     full_id: 'LLR-002')
    @software_llr_001 = LowLevelRequirement.find_by(item_id: @software_item.id,
                                                     full_id: 'LLR-001')
    @software_llr_002 = LowLevelRequirement.find_by(item_id: @software_item.id,
                                                     full_id: 'LLR-002')
    @model_file       = ModelFile.find_by(full_id: 'MF-001')
    @file_data        = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                     'image/png',
                                                     true)

    user_pm
  end

  test 'low level requirement record should be valid' do
    STDERR.puts('    Check to see that a Low Level Requirement Record with required fields filled in is valid.')
    assert_equals(true, @hardware_llr_001.valid?,
                  'Low Level Requirement Record',
                  '    Expect Low Level Requirement Record to be valid. It was valid.')
    STDERR.puts('    The Low Level Requirement Record was valid.')
  end

  test 'requirement ID shall be present for low level requirement' do
    STDERR.puts('    Check to see that a Low Level Requirement Record without a Requirement ID is invalid.')

    @hardware_llr_001.reqid = nil

    assert_equals(false, @hardware_llr_001.valid?,
                  'Low Level Requirement Record',
                  '    Expect Low Level Requirement without reqid not to be valid. It was not valid.')
    STDERR.puts('    The Low Level Requirement Record was invalid.')
  end

  test 'project id shall be present for low level requirement' do
    STDERR.puts('    Check to see that a Low Level Requirement Record without a Project ID is invalid.')

    @hardware_llr_001.project_id = nil

    assert_equals(false, @hardware_llr_001.valid?,
                  'Low Level Requirement Record',
                  '    Expect Low Level Requirement without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Low Level Requirement Record was invalid.')
  end

  test 'item id shall be present for low level requirement' do
    STDERR.puts('    Check to see that a Low Level Requirement Record without an Item ID is invalid.')

    @hardware_llr_001.item_id = nil

    assert_equals(false, @hardware_llr_001.valid?,
                  'Low Level Requirement Record',
                  '    Expect Low Level Requirement without item_id not to be valid. It was not valid.')
    STDERR.puts('    The Low Level Requirement Record was invalid.')
  end

  test 'full id shall be present for low level requirement' do
    STDERR.puts('    Check to see that a Low Level Requirement Record without a Full ID is invalid.')

    @hardware_llr_001.full_id = nil

    assert_equals(false, @hardware_llr_001.valid?,
                  'Low Level Requirement Record',
                  '    Expect Low Level Requirement without full_id not to be valid. It was not valid.')
    STDERR.puts('    The Low Level Requirement Record was invalid.')
  end

  test 'description shall be present for low level requirement' do
    STDERR.puts('    Check to see that a Low Level Requirement Record without a Description is invalid.')

    @hardware_llr_001.description = nil

    assert_equals(false, @hardware_llr_001.valid?,
                  'Low Level Requirement Record',
                  '    Expect Low Level Requirement without description not to be valid. It was not valid.')
    STDERR.puts('    The Low Level Requirement Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Low Level Requirement' do
    STDERR.puts('    Check to see that a Low Level Requirement can be created.')

    low_level_requirement = LowLevelRequirement.new({
                                                        reqid:                               @hardware_llr_001.reqid,
                                                        full_id:                             @hardware_llr_001.full_id,
                                                        description:                         @hardware_llr_001.description,
                                                        safety:                              @hardware_llr_001.safety,
                                                        version:                             @hardware_llr_001.version,
                                                        project_id:                          @hardware_llr_001.project_id,
                                                        item_id:                             @hardware_llr_001.item_id,
                                                        category:                            @hardware_llr_001.category,
                                                        verification_method:                 @hardware_llr_001.verification_method,
                                                        high_level_requirement_associations: @hardware_llr_001.high_level_requirement_associations,
                                                        model_file_id:                       @hardware_llr_001.model_file_id,
                                                        organization:                        @hardware_llr_001.organization
                                                      })

    assert_not_equals_nil(low_level_requirement.save, 'Low Level Requirement Record', '    Expect Low Level Requirement Record to be created. It was.')
    STDERR.puts('    A Low Level Requirement was successfully created.')
  end

  test 'should update Low Level Requirement' do
    STDERR.puts('    Check to see that a Low Level Requirement can be updated.')

    full_id                    = @hardware_llr_001.full_id.dup
    @hardware_llr_001.full_id += '_001'

    assert_not_equals_nil(@hardware_llr_001.save, 'Low Level Requirement Record', '    Expect Low Level Requirement Record to be updated. It was.')

    @hardware_llr_001.full_id  = full_id
    STDERR.puts('    A Low Level Requirement was successfully updated.')
  end

  test 'should delete Low Level Requirement' do
    STDERR.puts('    Check to see that a Low Level Requirement can be deleted.')
    assert(@hardware_llr_001.destroy)
    STDERR.puts('    A Low Level Requirement was successfully deleted.')
  end

  test 'should create Low Level Requirement with undo/redo' do
    STDERR.puts('    Check to see that a Low Level Requirement can be created, then undone and then redone.')

    low_level_requirement = LowLevelRequirement.new({
                                                        reqid:                               @hardware_llr_001.reqid,
                                                        full_id:                             @hardware_llr_001.full_id,
                                                        description:                         @hardware_llr_001.description,
                                                        safety:                              @hardware_llr_001.safety,
                                                        version:                             @hardware_llr_001.version,
                                                        project_id:                          @hardware_llr_001.project_id,
                                                        item_id:                             @hardware_llr_001.item_id,
                                                        category:                            @hardware_llr_001.category,
                                                        verification_method:                 @hardware_llr_001.verification_method,
                                                        high_level_requirement_associations: @hardware_llr_001.high_level_requirement_associations,
                                                        model_file_id:                       @hardware_llr_001.model_file_id,
                                                        organization:                        @hardware_llr_001.organization
                                                      })
    data_change            = DataChange.save_or_destroy_with_undo_session(low_level_requirement, 'create')

    assert_not_equals_nil(data_change, 'Low Level Requirement Record', '    Expect Low Level Requirement Record to be created. It was.')

    assert_difference('LowLevelRequirement.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('LowLevelRequirement.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Low Level Requirement was successfully created, then undone and then redone.')
  end

  test 'should update Low Level Requirement with undo/redo' do
    STDERR.puts('    Check to see that a Low Level Requirement can be updated, then undone and then redone.')

    full_id                    = @hardware_llr_001.full_id.dup
    @hardware_llr_001.full_id += '_001'
    data_change                = DataChange.save_or_destroy_with_undo_session(@hardware_llr_001, 'update')
    @hardware_llr_001.full_id  = full_id

    assert_not_equals_nil(data_change, 'Low Level Requirement Record', '    Expect Low Level Requirement Record to be updated. It was')
    assert_not_equals_nil(LowLevelRequirement.find_by(full_id: @hardware_llr_001.full_id + '_001', item_id: @hardware_item.id), 'Low Level Requirement Record', "    Expect Low Level Requirement Record's ID to be #{@hardware_llr_001.full_id + '_001'}. It was.")
    assert_equals(nil, LowLevelRequirement.find_by(full_id: @hardware_llr_001.full_id, item_id: @hardware_item.id), 'Low Level Requirement Record', '    Expect original Low Level Requirement Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, LowLevelRequirement.find_by(full_id: @hardware_llr_001.full_id + '_001', item_id: @hardware_item.id), 'Low Level Requirement Record', "    Expect updated Low Level Requirement's Record not to found. It was not found.")
    assert_not_equals_nil(LowLevelRequirement.find_by(full_id: @hardware_llr_001.full_id, item_id: @hardware_item.id), 'Low Level Requirement Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(LowLevelRequirement.find_by(full_id: @hardware_llr_001.full_id + '_001', item_id: @hardware_item.id), 'Low Level Requirement Record', "    Expect updated Low Level Requirement's Record to be found. It was found.")
    assert_equals(nil, LowLevelRequirement.find_by(full_id: @hardware_llr_001.full_id, item_id: @hardware_item.id), 'Low Level Requirement Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Low Level Requirement was successfully updated, then undone and then redone.')
  end

  test 'should delete Low Level Requirement with undo/redo' do
    STDERR.puts('    Check to see that a Low Level Requirement can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@hardware_llr_001, 'delete')

    assert_not_equals_nil(data_change, 'Low Level Requirement Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, LowLevelRequirement.find_by(reqid: @hardware_llr_001.reqid, item_id: @hardware_item.id), 'Low Level Requirement Record', '    Verify that the Low Level Requirement Record was actually deleted. It was.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(LowLevelRequirement.find_by(reqid: @hardware_llr_001.reqid, item_id: @hardware_item.id), 'Low Level Requirement Record', '    Verify that the Low Level Requirement Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, LowLevelRequirement.find_by(reqid: @hardware_llr_001.reqid, item_id: @hardware_item.id), 'Low Level Requirement Record', '    Verify that the Low Level Requirement Record was deleted again after redo. It was.')
    STDERR.puts('    A High Level Requirement was successfully deleted, then undone and then redone.')
  end

  test 'fullreqid should be correct' do
    STDERR.puts('    Check to see that the Low Level Requirement returns a proper Full ID.')

    @hardware_llr_001.fullreqid

    assert_equals('LLR-001', @hardware_llr_001.fullreqid, 'Low Level Requirement Record', '    Expect fullreqid with full_id to be "LLR-001". It was.')

    @hardware_llr_001.full_id = nil

    assert_equals('1:HARDWARE_ITEM', @hardware_llr_001.fullreqid, 'Low Level Requirement Record', '    Expect fullreqid without full_id to be ""1:HARDWARE_ITEM". It was.')
    STDERR.puts('    The Low Level Requirement returns a proper Full ID successfully.')
  end

  test 'reqplusdescription should be correct' do
    STDERR.puts('    Check to see that the Low Level Requirement returns a proper Full ID with Description.')
    @hardware_llr_001.fullreqid

    assert_equals('LLR-001: The System SHALL keep the pump pressure below 4700 psia.', @hardware_llr_001.reqplusdescription, 'Low Level Requirement Record', '    Expect fullreqid with full_id to be "LLR-001: The System SHALL monitor the check value to prevent over-pressure.". It was.')

    @hardware_llr_001.full_id = nil

    assert_equals('1:HARDWARE_ITEM: The System SHALL keep the pump pressure below 4700 psia.', @hardware_llr_001.reqplusdescription, 'Low Level Requirement Record', '    Expect fullreqid without full_id to be "1:HARDWARE_ITEM: The System SHALL keep the pump pressure below 4700 psia.". It was.')
    STDERR.puts('    The Low Level Requirement returned a proper Full ID with Description successfully.')
  end

  test 'get_high_level_requirement should return the High Level Requirement' do
    STDERR.puts('    Check to see that the Low Level Requirement can return an associated High-Level Requirement.')
    assert_not_equals_nil(@hardware_llr_001.get_high_level_requirement, 'High Level Requirement Record', '    Expect get_high_level_requirement to get a High Level Requirement. It did.')
    STDERR.puts('    The Low Level Requirement returned  an associated High-Level Requirement successfully.')
  end

  test 'get_system_requirement should return the System Requirement' do
    STDERR.puts('    Check to see that the Low Level Requirement can return an associated System Requirement.')
    assert_not_equals_nil(@hardware_llr_001.get_system_requirement,
                          'System Requirement Record',
                          '    Expect get_system_requirement to get a System Requirement. It did.')
    STDERR.puts('    The Low Level Requirement returned  an associated System Requirement successfully.')
  end

  test 'should add model' do
    STDERR.puts('    Check to see that the Low Level Requirement can attach a model file.')
    model_file            = ModelFile.find(@hardware_llr_001.model_file_id)
    model_file.project_id = @hardware_llr_001.project_id
    model_file.item_id    = @hardware_llr_001.item_id

    model_file.save!
    assert_not_equals_nil(@hardware_llr_001.add_model_document(@file_data, nil), 'Low Level Requirement Record', '    Expect add_model_document to add a model document to a Low Level Requirement. It did.')
    STDERR.puts('    The Low Level Requirement attached a model file successfully.')
  end

  test 'should rename prefix' do
    STDERR.puts('    Check to see that the Low Level Requirement rename its prefix.')
    original_llrs = LowLevelRequirement.where(item_id: @hardware_item.id)
    original_llrs = original_llrs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    LowLevelRequirement.rename_prefix(@project.id, @hardware_item.id,
                                       'LLR', 'Low Level Requirement')

    renamed_llrs  = LowLevelRequirement.where(item_id: @hardware_item.id)
    renamed_llrs  = renamed_llrs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    original_llrs.each_with_index do |llr, index|
      expected_id = llr.full_id.sub('LLR', 'Low Level Requirement')
      renamed_llr = renamed_llrs[index]

      assert_equals(expected_id, renamed_llr.full_id, 'Low Level Requirement Full ID', "    Expect full_id to be #{expected_id}. It was.")
    end

    STDERR.puts('    The Low Level Requirement renamed its prefix successfully.')
  end

  test 'should renumber' do
    STDERR.puts('    Check to see that the Low Level Requirement can renumber the LLRs.')

    original_llrs = LowLevelRequirement.where(item_id: @hardware_item.id)
    original_llrs = original_llrs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    LowLevelRequirement.renumber(@hardware_item.id, 10, 10,
                                  'Low Level Requirement')

    renumbered_llrs = LowLevelRequirement.where(item_id: @hardware_item.id)
    renumbered_llrs = renumbered_llrs.to_a.sort { |x, y| x.full_id <=> y.full_id}
    number          = 10

    original_llrs.each_with_index do |llr, index|
      expected_id    = llr.full_id.sub('LLR', 'Low Level Requirement').sub(/\-\d{3}/, sprintf('-%03d', number))
      renumbered_llr = renumbered_llrs[index]

      assert_equals(expected_id, renumbered_llr.full_id, 'Low Level Requirement Full ID', "    Expect full_id to be #{expected_id}. It was.")
      number        += 10
    end

    STDERR.puts('    The Low Level Requirement renumbered the LLRs successfully.')
  end

  test 'should get columns' do
    STDERR.puts('    Check to see that the Low Level Requirement can return the columns.')

    columns = @hardware_llr_001.get_columns
    columns = columns[1..10] + columns[13..18]

    assert_equals([
                     1,
                     "LLR-001",
                     "The System SHALL keep the pump pressure below 4700 psia.",
                     nil,
                     nil,
                     0,
                     "HARDWARE_ITEM",
                     "Test",
                     "HLR-001",
                     nil,
                     "test",
                     "Safety",
                     "Test",
                     true,
                     nil,
                     ""
                  ],
                  columns, 'Columns',
                  '    Expect columns to be [1, "LLR-001", "The System SHALL keep the pump pressure below 4700 psia.", nil, 0, "HARDWARE_ITEM", "Test", "HLR-001", nil, "test", "Safety", "Test", true, nil, "", "MF-001"]. It was.')
    STDERR.puts('    The Low Level Requirement returned the columns successfully.')
  end

  test 'should generate CSV' do
    STDERR.puts('    Check to see that the Low Level Requirement can generate CSV properly.')
    csv   = LowLevelRequirement.to_csv(@hardware_item.id)
    lines = csv.split("\n")

    assert_equals('id,reqid,full_id,description,module_description,derived,version,item_id,project_id,high_level_requirement_associations,derived_justification,created_at,updated_at,organization,category,verification_method,safety,soft_delete,document_id,model_file_id,archive_revision,archive_version',
                  lines[0], 'Header',
                  '    Expect header to be "id,reqid,full_id,description,module_description,derived,version,item_id,project_id,high_level_requirement_associations,derived_justification,created_at,updated_at,organization,category,verification_method,safety,soft_delete,document_id,model_file_id,archive_revision,archive_version". It was.')

    lines[1..-1].each do |line|
      assert_not_equals_nil((line =~ /^\d+,\d,LLR-\d{3},.+$/),
                            '    Expect line to be /^^\d+,\d,LLR-\d{3},.+$/. It was.')
    end

    STDERR.puts('    The Low Level Requirement generated CSV successfully.')
  end

  test 'should generate XLS' do
    STDERR.puts('    Check to see that the Low Level Requirement can generate XLS properly.')

    assert_nothing_raised do
      xls = LowLevelRequirement.to_xls(@hardware_item.id)

      assert_not_equals_nil(xls, 'XLS Data', '    Expect XLS Data to not be nil. It was.')
    end

    STDERR.puts('    The Low Level Requirement generated XLS successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the Low Level Requirement can assign columns properly.')

    llr = LowLevelRequirement.new()

    assert(llr.assign_column('id', '1', @hardware_item.id))
    assert(llr.assign_column('project_id', 'Test', @hardware_item.id))
    assert_equals(@project.id, llr.project_id, 'Project ID',
                  "    Expect Project ID to be #{@project.id}. It was.")
    assert(llr.assign_column('item_id', 'HARDWARE_ITEM', @hardware_item.id))
    assert_equals(@hardware_item.id, llr.item_id, 'Item ID',
                  "    Expect Item ID to be #{@hardware_item.id}. It was.")
    assert(llr.assign_column('reqid', @hardware_llr_001.reqid.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_llr_001.reqid, llr.reqid, 'Requirement ID',
                  "    Expect Requirement ID to be #{@hardware_llr_001.reqid}. It was.")
    assert(llr.assign_column('full_id', @hardware_llr_001.full_id,
                             @hardware_item.id))
    assert_equals(@hardware_llr_001.full_id, llr.full_id, 'Full ID',
                  "    Expect Full ID to be #{@hardware_llr_001.full_id}. It was.")
    assert(llr.assign_column('description', @hardware_llr_001.description,
                             @hardware_item.id))
    assert_equals(@hardware_llr_001.description, llr.description, 'Description',
                  "    Expect Description to be #{@hardware_llr_001.description}. It was.")
    assert(llr.assign_column('category', @hardware_llr_001.category,
                             @hardware_item.id))
    assert_equals(@hardware_llr_001.category, llr.category, 'Category',
                  "    Expect Category to be #{@hardware_llr_001.category}. It was.")
    assert(llr.assign_column('verification_method',
                             @hardware_llr_001.verification_method.join(','),
                             @hardware_item.id))
    assert_equals(@hardware_llr_001.verification_method, llr.verification_method, 'Verification Method',
                  "    Expect Verification Method to be #{@hardware_llr_001.verification_method.join(',')}. It was.")
    assert(llr.assign_column('derived', 'true', @hardware_item.id))
    assert_equals(true, llr.derived, 'Derived',
                  "    Expect Derived from 'true' to be true. It was.")
    assert(llr.assign_column('derived', 'false', @hardware_item.id))
    assert_equals(false, llr.derived, 'Derived',
                  "    Expect Derived from 'false' to be false. It was.")
    assert(llr.assign_column('derived', 'yes', @hardware_item.id))
    assert_equals(true, llr.derived, 'Derived',
                  "    Expect Derived from 'yes' to be true. It was.")
    assert(llr.assign_column('derived_justification', 'Because', @hardware_item.id))
    assert_equals('Because', llr.derived_justification, 'Derived Justification',
                  "    Expect Derived Justification to be 'Because'. It was.")
    assert(llr.assign_column('safety', 'true', @hardware_item.id))
    assert_equals(true, llr.safety, 'Safety',
                  "    Expect Safety from 'true' to be true. It was.")
    assert(llr.assign_column('safety', 'false', @hardware_item.id))
    assert_equals(false, llr.safety, 'Safety',
                  "    Expect Safety from 'false' to be false. It was.")
    assert(llr.assign_column('safety', 'yes', @hardware_item.id))
    assert_equals(true, llr.safety, 'Safety',
                  "    Expect Safety from 'yes' to be true. It was.")
    assert(llr.assign_column('version', @hardware_llr_001.version.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_llr_001.version, llr.version, 'Version',
                  "    Expect Version to be #{@hardware_llr_001.version}. It was.")
    assert(llr.assign_column('high_level_requirement_associations', 'HLR-001',
                             @hardware_item.id))
    assert_equals(@hardware_llr_001.high_level_requirement_associations,
                  llr.high_level_requirement_associations,
                  'High Level Requirement ID',
                  "    Expect High Level Requirement ID to be #{@hardware_llr_001.high_level_requirement_associations}. It was.")
    assert(llr.assign_column('document_id', 'PHAC', @hardware_item.id))
    assert_equals(Document.find_by(docid: 'PHAC').try(:id),
                  llr.document_id,
                  'Document ID',
                  "    Expect Document ID to be #{Document.find_by(docid: 'PHAC').try(:id)}. It was.")
    assert(llr.assign_column('model_file_id', 'MF-001',
                             @hardware_item.id))
    assert_equals(@hardware_llr_001.model_file_id, llr.model_file_id,
                  'Model File ID',
                  "    Expect Model File ID to be #{@hardware_llr_001.model_file_id}. It was.")
    assert(llr.assign_column('created_at', @hardware_llr_001.created_at.to_s,
                             @hardware_item.id))
    assert(llr.assign_column('updated_at', @hardware_llr_001.updated_at.to_s,
                             @hardware_item.id))
    assert(llr.assign_column('organization', @hardware_llr_001.organization,
                             @hardware_item.id))
    assert(llr.assign_column('soft_delete', 'true', @hardware_item.id))
    assert_equals(true, llr.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'true' to be true. It was.")
    assert(llr.assign_column('soft_delete', 'false', @hardware_item.id))
    assert_equals(false, llr.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'false' to be false. It was.")
    assert(llr.assign_column('soft_delete', 'yes', @hardware_item.id))
    assert_equals(true, llr.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'yes' to be true. It was.")
    STDERR.puts('    The Low Level Requirement assigned the columns successfully.')
  end

  test 'should parse CSV string' do
    STDERR.puts('    Check to see that the Low Level Requirement can parse CSV properly.')

    attributes = [
                    'description',
                    'category',
                    'verification_method',
                    'safety',
                    'derived',
                    'version',
                    'item_id',
                    'project_id',
                    'derived_justification',
                    'organization',
                    'archive_id',
                    'high_level_requirement_associations',
                    'soft_delete',
                    'document_id',
                    'model_file_id'
                 ]
    csv        = LowLevelRequirement.to_csv(@hardware_item.id)
    lines      = csv.split("\n")

#    assert_equals(:duplicate_low_level_requirement,
#                  LowLevelRequirement.from_csv_string(lines[1],
#                                                      @hardware_item,
#                                                      [ :check_duplicates ]),
#                  'Low Level Requirement Records',
#                  '    Expect Duplicate Low Level Requirement Records to error. They did.')

    line       = lines[1].gsub('HLR-001', 'HLR-002')

    assert_equals(:high_level_requirement_associations_changed,
                  LowLevelRequirement.from_csv_string(line,
                                                       @hardware_item,
                                                       [ :check_associations ]),
                  'Low Level Requirement Records',
                  '    Expect Changed Associations Records to error. They did.')

    line       = lines[1].gsub('1,LLR-001', '4,LLR-004')

#    assert(LowLevelRequirement.from_csv_string(line, @hardware_item))

    llr        = LowLevelRequirement.find_by(full_id: 'LLR-004')

#    assert_equals(true, compare_llrs(@hardware_llr_001, llr, attributes),
#                  'Low Level Requirement Records',
#                  '    Expect Low Level Requirement Records to match. They did.')
    STDERR.puts('    The Low Level Requirement parsed CSV successfully.')
  end

  test 'should parse files' do
    STDERR.puts('    Check to see that the Low Level Requirement can parse files properly.')

    assert_equals(:duplicate_low_level_requirement,
                  LowLevelRequirement.from_file('test/fixtures/files/Hardware Item-Low_Level_Requirements.csv',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Low Level Requirement Records from Hardware Item-Low_Level_Requirements.csv',
                  '    Expect Duplicate Low Level Requirement Records to error. They did.')
    assert_equals(true,
                  LowLevelRequirement.from_file('test/fixtures/files/Hardware Item-Low_Level_Requirements.csv',
                                                 @hardware_item),
                  'Low Level Requirement Records From Hardware Item-Low_Level_Requirements.csv',
                  '    Expect Changed Low Level Requirement Associations Records  from Hardware Item-Low_Level_Requirements.csv to error. They did.')
    assert_equals(:duplicate_low_level_requirement,
                  LowLevelRequirement.from_file('test/fixtures/files/Hardware Item-Low_Level_Requirements.xls',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Low Level Requirement Records from Hardware Item-Low_Level_Requirements.csv',
                  '    Expect Duplicate Low Level Requirement Records to error. They did.')
    assert_equals(true,
                  LowLevelRequirement.from_file('test/fixtures/files/Hardware Item-Low_Level_Requirements.xls',
                                                 @hardware_item),
                  'Low Level Requirement Records From Hardware Item-Low_Level_Requirements.csv',
                  '    Expect Changed Low Level Requirement Associations Records  from Hardware Item-Low_Level_Requirements.csv to error. They did.')
    assert_equals(:duplicate_low_level_requirement,
                  LowLevelRequirement.from_file('test/fixtures/files/Hardware Item-Low_Level_Requirements.xlsx',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'Low Level Requirement Records from Hardware Item-Low_Level_Requirements.csv',
                  '    Expect Duplicate Low Level Requirement Records to error. They did.')
    assert_equals(true,
                  LowLevelRequirement.from_file('test/fixtures/files/Hardware Item-Low_Level_Requirements.xlsx',
                                                 @hardware_item),
                  'Low Level Requirement Records From Hardware Item-Low_Level_Requirements.csv',
                  '    Expect Changed Low Level Requirement Associations Records  from Hardware Item-Low_Level_Requirements.csv to error. They did.')

    STDERR.puts('    The Low Level Requirement parsed files successfully.')
  end
end

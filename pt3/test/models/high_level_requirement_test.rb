require 'test_helper'

class HighLevelRequirementTest < ActiveSupport::TestCase
  def compare_hlrs(x, y,
                   attributes = [
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
        break
      end
    end

    return result
  end

  def setup
    @project          = Project.find_by(identifier: 'TEST')
    @hardware_item    = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item    = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_hlr_001 = HighLevelRequirement.find_by(item_id: @hardware_item.id,
                                                     full_id: 'HLR-001')
    @hardware_hlr_002 = HighLevelRequirement.find_by(item_id: @hardware_item.id,
                                                     full_id: 'HLR-002')
    @software_hlr_001 = HighLevelRequirement.find_by(item_id: @software_item.id,
                                                     full_id: 'HLR-001')
    @software_hlr_002 = HighLevelRequirement.find_by(item_id: @software_item.id,
                                                     full_id: 'HLR-002')
    @model_file       = ModelFile.find_by(full_id: 'MF-001')
    @file_data        = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                     'image/png',
                                                     true)

    user_pm
  end

  test 'high level requirement record should be valid' do
    STDERR.puts('    Check to see that a High Level Requirement Record with required fields filled in is valid.')
    assert_equals(true, @hardware_hlr_001.valid?,
                  'High Level Requirement Record',
                  '    Expect High Level Requirement Record to be valid. It was valid.')
    STDERR.puts('    The High Level Requirement Record was valid.')
  end

  test 'requirement ID shall be present for high level requirement' do
    STDERR.puts('    Check to see that a High Level Requirement Record without a Requirement ID is invalid.')

    @hardware_hlr_001.reqid = nil

    assert_equals(false, @hardware_hlr_001.valid?,
                  'High Level Requirement Record',
                  '    Expect High Level Requirement without reqid not to be valid. It was not valid.')
    STDERR.puts('    The High Level Requirement Record was invalid.')
  end

  test 'project id shall be present for high level requirement' do
    STDERR.puts('    Check to see that a High Level Requirement Record without a Project ID is invalid.')

    @hardware_hlr_001.project_id = nil

    assert_equals(false, @hardware_hlr_001.valid?,
                  'High Level Requirement Record',
                  '    Expect High Level Requirement without project_id not to be valid. It was not valid.')
    STDERR.puts('    The High Level Requirement Record was invalid.')
  end

  test 'item id shall be present for high level requirement' do
    STDERR.puts('    Check to see that a High Level Requirement Record without an Item ID is invalid.')

    @hardware_hlr_001.item_id = nil

    assert_equals(false, @hardware_hlr_001.valid?,
                  'High Level Requirement Record',
                  '    Expect High Level Requirement without item_id not to be valid. It was not valid.')
    STDERR.puts('    The High Level Requirement Record was invalid.')
  end

  test 'full id shall be present for high level requirement' do
    STDERR.puts('    Check to see that a High Level Requirement Record without a Full ID is invalid.')

    @hardware_hlr_001.full_id = nil

    assert_equals(false, @hardware_hlr_001.valid?, 'High Level Requirement Record', '    Expect High Level Requirement without full_id not to be valid. It was not valid.')
    STDERR.puts('    The High Level Requirement Record was invalid.')
  end

  test 'description shall be present for high level requirement' do
    STDERR.puts('    Check to see that a High Level Requirement Record without a Description is invalid.')

    @hardware_hlr_001.description = nil

    assert_equals(false, @hardware_hlr_001.valid?, 'High Level Requirement Record', '    Expect High Level Requirement without description not to be valid. It was not valid.')
    STDERR.puts('    The High Level Requirement Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create High Level Requirement' do
    STDERR.puts('    Check to see that a High Level Requirement can be created.')

    high_level_requirement = HighLevelRequirement.new({
                                                        reqid:                           @hardware_hlr_001.reqid,
                                                        full_id:                         @hardware_hlr_001.full_id,
                                                        description:                     @hardware_hlr_001.description,
                                                        safety:                          @hardware_hlr_001.safety,
                                                        version:                         @hardware_hlr_001.version,
                                                        project_id:                      @hardware_hlr_001.project_id,
                                                        item_id:                         @hardware_hlr_001.item_id,
                                                        category:                        @hardware_hlr_001.category,
                                                        verification_method:             @hardware_hlr_001.verification_method,
                                                        system_requirement_associations: @hardware_hlr_001.system_requirement_associations,
                                                        model_file_id:                   @hardware_hlr_001.model_file_id,
                                                        organization:                    @hardware_hlr_001.organization
                                                      })

    assert_not_equals_nil(high_level_requirement.save, 'High Level Requirement Record', '    Expect High Level Requirement Record to be created. It was.')
    STDERR.puts('    A High Level Requirement was successfully created.')
  end

  test 'should update High Level Requirement' do
    STDERR.puts('    Check to see that a High Level Requirement can be updated.')

    full_id                    = @hardware_hlr_001.full_id.dup
    @hardware_hlr_001.full_id += '_001'

    assert_not_equals_nil(@hardware_hlr_001.save, 'High Level Requirement Record', '    Expect High Level Requirement Record to be updated. It was.')

    @hardware_hlr_001.full_id  = full_id
    STDERR.puts('    A High Level Requirement was successfully updated.')
  end

  test 'should delete High Level Requirement' do
    STDERR.puts('    Check to see that a High Level Requirement can be deleted.')
    assert(@hardware_hlr_001.destroy)
    STDERR.puts('    A High Level Requirement was successfully deleted.')
  end

  test 'should create High Level Requirement with undo/redo' do
    STDERR.puts('    Check to see that a High Level Requirement can be created, then undone and then redone.')

    high_level_requirement = HighLevelRequirement.new({
                                                        reqid:                           @hardware_hlr_001.reqid,
                                                        full_id:                         @hardware_hlr_001.full_id,
                                                        description:                     @hardware_hlr_001.description,
                                                        safety:                          @hardware_hlr_001.safety,
                                                        version:                         @hardware_hlr_001.version,
                                                        project_id:                      @hardware_hlr_001.project_id,
                                                        item_id:                         @hardware_hlr_001.item_id,
                                                        category:                        @hardware_hlr_001.category,
                                                        verification_method:             @hardware_hlr_001.verification_method,
                                                        system_requirement_associations: @hardware_hlr_001.system_requirement_associations,
                                                        model_file_id:                   @hardware_hlr_001.model_file_id,
                                                        organization:                    @hardware_hlr_001.organization
                                                      })
    data_change            = DataChange.save_or_destroy_with_undo_session(high_level_requirement, 'create')

    assert_not_equals_nil(data_change, 'High Level Requirement Record', '    Expect High Level Requirement Record to be created. It was.')

    assert_difference('HighLevelRequirement.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('HighLevelRequirement.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A High Level Requirement was successfully created, then undone and then redone.')
  end

  test 'should update High Level Requirement with undo/redo' do
    STDERR.puts('    Check to see that a High Level Requirement can be updated, then undone and then redone.')

    full_id                    = @hardware_hlr_001.full_id.dup
    @hardware_hlr_001.full_id += '_001'
    data_change                = DataChange.save_or_destroy_with_undo_session(@hardware_hlr_001, 'update')
    @hardware_hlr_001.full_id  = full_id

    assert_not_equals_nil(data_change, 'High Level Requirement Record', '    Expect High Level Requirement Record to be updated. It was')
    assert_not_equals_nil(HighLevelRequirement.find_by(full_id: @hardware_hlr_001.full_id + '_001', item_id: @hardware_item.id), 'High Level Requirement Record', "    Expect High Level Requirement Record's ID to be #{@hardware_hlr_001.full_id + '_001'}. It was.")
    assert_equals(nil, HighLevelRequirement.find_by(full_id: @hardware_hlr_001.full_id, item_id: @hardware_item.id), 'High Level Requirement Record', '    Expect original High Level Requirement Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, HighLevelRequirement.find_by(full_id: @hardware_hlr_001.full_id + '_001', item_id: @hardware_item.id), 'High Level Requirement Record', "    Expect updated High Level Requirement's Record not to found. It was not found.")
    assert_not_equals_nil(HighLevelRequirement.find_by(full_id: @hardware_hlr_001.full_id, item_id: @hardware_item.id), 'High Level Requirement Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(HighLevelRequirement.find_by(full_id: @hardware_hlr_001.full_id + '_001', item_id: @hardware_item.id), 'High Level Requirement Record', "    Expect updated High Level Requirement's Record to be found. It was found.")
    assert_equals(nil, HighLevelRequirement.find_by(full_id: @hardware_hlr_001.full_id, item_id: @hardware_item.id), 'High Level Requirement Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A High Level Requirement was successfully updated, then undone and then redone.')
  end

  test 'should delete High Level Requirement with undo/redo' do
    STDERR.puts('    Check to see that a High Level Requirement can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@hardware_hlr_001, 'delete')

    assert_not_equals_nil(data_change, 'High Level Requirement Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, HighLevelRequirement.find_by(reqid: @hardware_hlr_001.reqid, item_id: @hardware_item.id), 'High Level Requirement Record', '    Verify that the High Level Requirement Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(HighLevelRequirement.find_by(reqid: @hardware_hlr_001.reqid, item_id: @hardware_item.id), 'High Level Requirement Record', '    Verify that the High Level Requirement Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, HighLevelRequirement.find_by(reqid: @hardware_hlr_001.reqid, item_id: @hardware_item.id), 'High Level Requirement Record', '    Verify that the High Level Requirement Record was deleted again after redo. It was.')
    STDERR.puts('    A High Level Requirement was successfully deleted, then undone and then redone.')
  end

  test 'fullreqid should be correct' do
    STDERR.puts('    Check to see that the High Level Requirement returns a proper Full ID.')

    @hardware_hlr_001.fullreqid

    assert_equals('HLR-001', @hardware_hlr_001.fullreqid, 'High Level Requirement Record', '    Expect fullreqid with full_id to be "HLR-001". It was.')

    @hardware_hlr_001.full_id = nil

    assert_equals('1:HARDWARE_ITEM', @hardware_hlr_001.fullreqid, 'High Level Requirement Record', '    Expect fullreqid without full_id to be "1:HARDWARE_ITEM". It was.')
    STDERR.puts('    The High Level Requirement returns a proper Full ID successfully.')
  end

  test 'reqplusdescription should be correct' do
    STDERR.puts('    Check to see that the High Level Requirement returns a proper Full ID with Description.')
    @hardware_hlr_001.fullreqid

    assert_equals('HLR-001: The System SHALL monitor the check value to prevent over-pressure.', @hardware_hlr_001.reqplusdescription, 'HLR-001: The System SHALL monitor the check value to prevent over-pressure.". It was.')

    @hardware_hlr_001.full_id = nil

    assert_equals('1:HARDWARE_ITEM: The System SHALL monitor the check value to prevent over-pressure.', @hardware_hlr_001.reqplusdescription, 'High Level Requirement Record', '    Expect fullreqid without full_id to be "1:HARDWARE_ITEM: The System SHALL monitor the check value to prevent over-pressure.". It was.')
    STDERR.puts('    The High Level Requirement returned a proper Full ID with Description successfully.')
  end

  test 'get_system_requirement should return the System Requirement' do
    STDERR.puts('    Check to see that the High Level Requirement can return an associated System Requirement.')
    assert_not_equals_nil(@hardware_hlr_001.get_system_requirement, 'High Level Requirement Record', '    Expect get_system_requirement to get a System Requirement. It did.')
    STDERR.puts('    The High Level Requirement returned  an associated System Requirement successfully.')
  end

  test 'should add model' do
    STDERR.puts('    Check to see that the High Level Requirement can attach a model file.')
    model_file            = ModelFile.find(@hardware_hlr_001.model_file_id)
    model_file.project_id = @hardware_hlr_001.project_id
    model_file.item_id    = @hardware_hlr_001.item_id

    model_file.save!
    assert_not_equals_nil(@hardware_hlr_001.add_model_document(@file_data, nil), 'High Level Requirement Record', '    Expect add_model_document to add a model document to a High Level Requirement. It did.')
    STDERR.puts('    The High Level Requirement attached a model file successfully.')
  end

  test 'should rename prefix' do
    STDERR.puts('    Check to see that the High Level Requirement can rename its prefix.')
    original_hlrs = HighLevelRequirement.where(item_id: @hardware_item.id)
    original_hlrs = original_hlrs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    HighLevelRequirement.rename_prefix(@project.id, @hardware_item.id,
                                       'HLR', 'High Level Requirement')

    renamed_hlrs  = HighLevelRequirement.where(item_id: @hardware_item.id)
    renamed_hlrs  = renamed_hlrs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    original_hlrs.each_with_index do |hlr, index|
      expected_id = hlr.full_id.sub('HLR', 'High Level Requirement')
      renamed_hlr = renamed_hlrs[index]

      assert_equals(expected_id, renamed_hlr.full_id, 'High Level Requirement Full ID', "    Expect full_id to be #{expected_id}. It was.")
    end

    STDERR.puts('    The High Level Requirement renamed its prefix successfully.')
  end

  test 'should renumber' do
    STDERR.puts('    Check to see that the High Level Requirement can renumber the HLRs.')

    original_hlrs = HighLevelRequirement.where(item_id: @hardware_item.id)
    original_hlrs = original_hlrs.to_a.sort { |x, y| x.full_id <=> y.full_id}

    HighLevelRequirement.renumber(@hardware_item.id, 10, 10,
                                  'High Level Requirement')

    renumbered_hlrs = HighLevelRequirement.where(item_id: @hardware_item.id)
    renumbered_hlrs = renumbered_hlrs.to_a.sort { |x, y| x.full_id <=> y.full_id}
    number          = 10

    original_hlrs.each_with_index do |hlr, index|
      expected_id    = hlr.full_id.sub('HLR', 'High Level Requirement').sub(/\-\d{3}/, sprintf('-%03d', number))
      renumbered_hlr = renumbered_hlrs[index]

      assert_equals(expected_id, renumbered_hlr.full_id, 'High Level Requirement Full ID', "    Expect full_id to be #{expected_id}. It was.")
      number        += 10
    end

    STDERR.puts('    The High Level Requirement renumbered the HLRs successfully.')
  end

  test 'should get columns' do
    STDERR.puts('    Check to see that the High Level Requirement can return the columns.')

    columns = @hardware_hlr_001.get_columns
    columns = columns[1..13] + columns[16..22]

    assert_equals([1,
                   'HLR-001',
                   'The System SHALL monitor the check value to prevent over-pressure.',
                   'Safety', true, nil, nil, 'Inspection,Simulation,Test', 0, 'HARDWARE_ITEM', 'Test',
                   'SYS-001', nil, 'test', 'Test', nil, '', nil, '', 'MF-001'
                  ],
                  columns, 'Columns',
                  '    Expect columns to be [1, "HLR-001", "The System SHALL monitor the check value to prevent over-pressure.", "Safety", true, nil, nil, nil, 0, "HARDWARE_ITEM", "Test", "SYS-001", nil, "test", "Test", nil, "", nil, "", "MF-001"]. It was.')
    STDERR.puts('    The High Level Requirement returned the columns successfully.')
  end

  test 'should generate CSV' do
    STDERR.puts('    Check to see that the High Level Requirement can generate CSV properly.')

    csv   = HighLevelRequirement.to_csv(@hardware_item.id)
    lines = csv.split("\n")

    assert_equals('id,reqid,full_id,description,category,safety,robustness,derived,testmethod,version,item_id,project_id,system_requirement_associations,derived_justification,created_at,updated_at,organization,verification_method,archive_id,high_level_requirement_associations,soft_delete,document_id,model_file_id,archive_revision,archive_version',
                  lines[0], 'Header',
                  '    Expect header to be "id,reqid,full_id,description,category,safety,robustness,derived,testmethod,version,item_id,project_id,system_requirement_associations,derived_justification,created_at,updated_at,organization,verification_method,archive_id,high_level_requirement_associations,soft_delete,document_id,model_file_id,archive_revision,archive_version". It was.')

    lines[1..-1].each do |line|
      assert_not_equals_nil((line =~ /^\d+,\d,HLR-\d{3},.+$/),
                            '    Expect line to be /^\d+,\d,HLR-\d{3},.+$/. It was.')
    end

    STDERR.puts('    The High Level Requirement generated CSV successfully.')
  end

  test 'should generate XLS' do
    STDERR.puts('    Check to see that the High Level Requirement can generate XLS properly.')

    assert_nothing_raised do
      xls = HighLevelRequirement.to_xls(@hardware_item.id)

      assert_not_equals_nil(xls, 'XLS Data', '    Expect XLS Data to not be nil. It was.')
    end

    STDERR.puts('    The High Level Requirement generated XLS successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the High Level Requirement can assign columns properly.')

    hlr = HighLevelRequirement.new()

    assert(hlr.assign_column('id', '1', @hardware_item.id))
    assert(hlr.assign_column('project_id', 'Test', @hardware_item.id))
    assert_equals(@project.id, hlr.project_id, 'Project ID',
                  "    Expect Project ID to be #{@project.id}. It was.")
    assert(hlr.assign_column('item_id', 'HARDWARE_ITEM', @hardware_item.id))
    assert_equals(@hardware_item.id, hlr.item_id, 'Item ID',
                  "    Expect Item ID to be #{@hardware_item.id}. It was.")
    assert(hlr.assign_column('reqid', @hardware_hlr_001.reqid.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_hlr_001.reqid, hlr.reqid, 'Requirement ID',
                  "    Expect Requirement ID to be #{@hardware_hlr_001.reqid}. It was.")
    assert(hlr.assign_column('full_id', @hardware_hlr_001.full_id,
                             @hardware_item.id))
    assert_equals(@hardware_hlr_001.full_id, hlr.full_id, 'Full ID',
                  "    Expect Full ID to be #{@hardware_hlr_001.full_id}. It was.")
    assert(hlr.assign_column('description', @hardware_hlr_001.description,
                             @hardware_item.id))
    assert_equals(@hardware_hlr_001.description, hlr.description, 'Description',
                  "    Expect Description to be #{@hardware_hlr_001.description}. It was.")
    assert(hlr.assign_column('category', @hardware_hlr_001.category,
                             @hardware_item.id))
    assert_equals(@hardware_hlr_001.category, hlr.category, 'Category',
                  "    Expect Category to be #{@hardware_hlr_001.category}. It was.")
    assert(hlr.assign_column('verification_method',
                             @hardware_hlr_001.verification_method.join(','),
                             @hardware_item.id))
    assert_equals(@hardware_hlr_001.verification_method, hlr.verification_method, 'Verification Method',
                  "    Expect Verification Method to be #{@hardware_hlr_001.verification_method.join(',')}. It was.")
    assert(hlr.assign_column('testmethod',
                             @hardware_hlr_001.testmethod,
                             @hardware_item.id))
    assert_equals(@hardware_hlr_001.testmethod, hlr.testmethod, 'Test Method',
                  "    Expect Test Method to be #{@hardware_hlr_001.testmethod}. It was.")
    assert(hlr.assign_column('derived', 'true', @hardware_item.id))
    assert_equals(true, hlr.derived, 'Derived',
                  "    Expect Derived from 'true' to be true. It was.")
    assert(hlr.assign_column('derived', 'false', @hardware_item.id))
    assert_equals(false, hlr.derived, 'Derived',
                  "    Expect Derived from 'false' to be false. It was.")
    assert(hlr.assign_column('derived', 'yes', @hardware_item.id))
    assert_equals(true, hlr.derived, 'Derived',
                  "    Expect Derived from 'yes' to be true. It was.")
    assert(hlr.assign_column('derived_justification', 'Because', @hardware_item.id))
    assert_equals('Because', hlr.derived_justification, 'Derived Justification',
                  "    Expect Derived Justification to be 'Because'. It was.")
    assert(hlr.assign_column('safety', 'true', @hardware_item.id))
    assert_equals(true, hlr.safety, 'Safety',
                  "    Expect Safety from 'true' to be true. It was.")
    assert(hlr.assign_column('safety', 'false', @hardware_item.id))
    assert_equals(false, hlr.safety, 'Safety',
                  "    Expect Safety from 'false' to be false. It was.")
    assert(hlr.assign_column('safety', 'yes', @hardware_item.id))
    assert_equals(true, hlr.safety, 'Safety',
                  "    Expect Safety from 'yes' to be true. It was.")
    assert(hlr.assign_column('robustness', 'true', @hardware_item.id))
    assert_equals(true, hlr.robustness, 'Robustness',
                  "    Expect Robustness from 'true' to be true. It was.")
    assert(hlr.assign_column('robustness', 'false', @hardware_item.id))
    assert_equals(false, hlr.robustness, 'Robustness',
                  "    Expect Robustness from 'false' to be false. It was.")
    assert(hlr.assign_column('robustness', 'yes', @hardware_item.id))
    assert_equals(true, hlr.robustness, 'Robustness',
                  "    Expect Robustness from 'yes' to be true. It was.")
    assert(hlr.assign_column('version', @hardware_hlr_001.version.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_hlr_001.version, hlr.version, 'Version',
                  "    Expect Version to be #{@hardware_hlr_001.version}. It was.")
    assert(hlr.assign_column('system_requirement_associations', 'SYS-001',
                             @hardware_item.id))
    assert_equals(@hardware_hlr_001.system_requirement_associations,
                  hlr.system_requirement_associations,
                  'System Requirement ID',
                  "    Expect System Requirement ID to be #{@hardware_hlr_001.system_requirement_associations}. It was.")
    assert(hlr.assign_column('high_level_requirement_associations', 'HLR-001',
                             @software_item.id))
    assert_equals(@software_hlr_001.high_level_requirement_associations,
                  hlr.high_level_requirement_associations,
                  'High Level Requirement ID',
                  "    Expect High Level Requirement ID to be #{@software_hlr_001.high_level_requirement_associations}. It was.")
    assert(hlr.assign_column('document_id', 'PHAC', @hardware_item.id))
    assert_equals(Document.find_by(docid: 'PHAC').try(:id),
                  hlr.document_id,
                  'Document ID',
                  "    Expect Document ID to be #{Document.find_by(docid: 'PHAC').try(:id)}. It was.")
    assert(hlr.assign_column('model_file_id', 'MF-001',
                             @hardware_item.id))
    assert_equals(@hardware_hlr_001.model_file_id, hlr.model_file_id,
                  'Model File ID',
                  "    Expect Model File ID to be #{@hardware_hlr_001.model_file_id}. It was.")
    assert(hlr.assign_column('created_at', @hardware_hlr_001.created_at.to_s,
                             @hardware_item.id))
    assert(hlr.assign_column('updated_at', @hardware_hlr_001.updated_at.to_s,
                             @hardware_item.id))
    assert(hlr.assign_column('organization', @hardware_hlr_001.organization,
                             @hardware_item.id))
    assert(hlr.assign_column('soft_delete', 'true', @hardware_item.id))
    assert_equals(true, hlr.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'true' to be true. It was.")
    assert(hlr.assign_column('soft_delete', 'false', @hardware_item.id))
    assert_equals(false, hlr.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'false' to be false. It was.")
    assert(hlr.assign_column('soft_delete', 'yes', @hardware_item.id))
    assert_equals(true, hlr.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'yes' to be true. It was.")
    assert(hlr.assign_column('archive_revision', 'a', @hardware_item.id))
    assert(hlr.assign_column('archive_version', '1.1', @hardware_item.id))
    STDERR.puts('    The High Level Requirement assigned the columns successfully.')
  end

  test 'should parse CSV string' do
    STDERR.puts('    Check to see that the High Level Requirement can parse CSV properly.')

    attributes = [
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
    csv        = HighLevelRequirement.to_csv(@hardware_item.id)
    lines      = csv.split("\n")

    assert_equals(:duplicate_high_level_requirement,
                  HighLevelRequirement.from_csv_string(lines[1],
                                                      @hardware_item,
                                                      [ :check_duplicates ]),
                  'High Level Requirement Records',
                  '    Expect Duplicate High Level Requirement Records to error. They did.')

    line       = lines[1].gsub('SYS-001', 'SYS-002')

    assert_equals(:system_requirement_associations_changed,
                  HighLevelRequirement.from_csv_string(line,
                                                       @hardware_item,
                                                       [ :check_associations ]),
                  'High Level Requirement Records',
                  '    Expect Changed Associations Records to error. They did.')

    line       = lines[1].gsub('1,HLR-001', '4,HLR-004')

    assert(HighLevelRequirement.from_csv_string(line, @hardware_item))

    hlr        = HighLevelRequirement.find_by(full_id: 'HLR-004')

    assert_equals(true, compare_hlrs(@hardware_hlr_001, hlr, attributes),
                  'High Level Requirement Records',
                  '    Expect High Level Requirement Records to match. They did.')
    STDERR.puts('    The High Level Requirement parsed CSV successfully.')
  end

  test 'should parse files' do
    STDERR.puts('    Check to see that the High Level Requirement can parse files properly.')

    assert_equals(:duplicate_high_level_requirement,
                  HighLevelRequirement.from_file('test/fixtures/files/Hardware Item-High_Level_Requirements.csv',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'High Level Requirement Records from Hardware Item-High_Level_Requirements.csv',
                  '    Expect Duplicate High Level Requirement Records to error. They did.')
    assert_equals(true,
                  HighLevelRequirement.from_file('test/fixtures/files/Hardware Item-High_Level_Requirements.csv',
                                                 @hardware_item),
                  'High Level Requirement Records From Hardware Item-High_Level_Requirements.csv',
                  '    Expect Changed High Level Requirement Associations Records  from Hardware Item-High_Level_Requirements.csv to error. They did.')
    assert_equals(:duplicate_high_level_requirement,
                  HighLevelRequirement.from_file('test/fixtures/files/Hardware Item-High_Level_Requirements.xls',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'High Level Requirement Records from Hardware Item-High_Level_Requirements.csv',
                  '    Expect Duplicate High Level Requirement Records to error. They did.')
    assert_equals(true,
                  HighLevelRequirement.from_file('test/fixtures/files/Hardware Item-High_Level_Requirements.xls',
                                                 @hardware_item),
                  'High Level Requirement Records From Hardware Item-High_Level_Requirements.csv',
                  '    Expect Changed High Level Requirement Associations Records  from Hardware Item-High_Level_Requirements.csv to error. They did.')
    assert_equals(:duplicate_high_level_requirement,
                  HighLevelRequirement.from_file('test/fixtures/files/Hardware Item-High_Level_Requirements.xlsx',
                                                 @hardware_item,
                                                 [ :check_duplicates ]),
                  'High Level Requirement Records from Hardware Item-High_Level_Requirements.csv',
                  '    Expect Duplicate High Level Requirement Records to error. They did.')
    assert_equals(true,
                  HighLevelRequirement.from_file('test/fixtures/files/Hardware Item-High_Level_Requirements.xlsx',
                                                 @hardware_item),
                  'High Level Requirement Records From Hardware Item-High_Level_Requirements.csv',
                  '    Expect Changed High Level Requirement Associations Records  from Hardware Item-High_Level_Requirements.csv to error. They did.')
    STDERR.puts('    The High Level Requirement parsed files successfully.')
  end
end

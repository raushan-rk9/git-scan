require 'test_helper'

class ModuleDescriptionTest < ActiveSupport::TestCase
  def compare_mds(x, y,
                   attributes = [
                                  'module_description_number',
                                  'full_id',
                                  'description',
                                  'file_name',
                                  'version',
                                  'revision',
                                  'draft_revision',
                                  'revision_date',
                                  'high_level_requirement_associations',
                                  'low_level_requirement_associations',
                                  'soft_delete',
                                  'item_id',
                                  'project_id',
                                  'organization',
                                  'archive_id',
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
    @software_mds_001 = ModuleDescription.find_by(item_id: @software_item.id,
                                                  full_id: 'MD-001')
    @software_mds_002 = ModuleDescription.find_by(item_id: @software_item.id,
                                                  full_id: 'MD-002')
    @hardware_mds_005 = ModuleDescription.find_by(item_id: @hardware_item.id,
                                                  full_id: 'MD-005')
    @hardware_mds_005 = ModuleDescription.find_by(item_id: @hardware_item.id,
                                                  full_id: 'MD-006')
    user_pm
  end

  test 'module description requirement record should be valid' do
    STDERR.puts('    Check to see that a Module Description Record with required fields filled in is valid.')
    assert_equals(true, @hardware_mds_005.valid?,
                  'Module Description Record',
                  '    Expect Module Description Record to be valid. It was valid.')
    STDERR.puts('    The Module Description Record was valid.')
  end

  test 'requirement ID shall be present for module description requirement' do
    STDERR.puts('    Check to see that a Module Description Record without a Requirement ID is invalid.')

    @hardware_mds_005.module_description_number = nil

    assert_equals(false, @hardware_mds_005.valid?,
                  'Module Description Record',
                  '    Expect Module Description without module_description_number not to be valid. It was not valid.')
    STDERR.puts('    The Module Description Record was invalid.')
  end

  test 'project id shall be present for module description requirement' do
    STDERR.puts('    Check to see that a Module Description Record without a Project ID is invalid.')

    @hardware_mds_005.project_id = nil

    assert_equals(false, @hardware_mds_005.valid?,
                  'Module Description Record',
                  '    Expect Module Description without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Module Description Record was invalid.')
  end

  test 'item id shall be present for module description requirement' do
    STDERR.puts('    Check to see that a Module Description Record without an Item ID is invalid.')

    @hardware_mds_005.item_id = nil

    assert_equals(false, @hardware_mds_005.valid?,
                  'Module Description Record',
                  '    Expect Module Description without item_id not to be valid. It was not valid.')
    STDERR.puts('    The Module Description Record was invalid.')
  end

  test 'full id shall be present for module description requirement' do
    STDERR.puts('    Check to see that a Module Description Record without a Full ID is invalid.')

    @hardware_mds_005.full_id = nil

    assert_equals(false, @hardware_mds_005.valid?, 'Module Description Record', '    Expect Module Description without full_id not to be valid. It was not valid.')
    STDERR.puts('    The Module Description Record was invalid.')
  end

  test 'description shall be present for module description requirement' do
    STDERR.puts('    Check to see that a Module Description Record without a Description is invalid.')

    @hardware_mds_005.description = nil

    assert_equals(false, @hardware_mds_005.valid?, 'Module Description Record', '    Expect Module Description without description not to be valid. It was not valid.')
    STDERR.puts('    The Module Description Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Module Description' do
    STDERR.puts('    Check to see that a Module Description can be created.')

    module_description = ModuleDescription.new({
                                                  full_id:                             'MD-003',
                                                  description:                         'Safety.',
                                                  file_name:                           'alert_overpressure.c' ,
                                                  version:                             1,
                                                  draft_revision:                      1.0,
                                                  revision_date:                       2021-05-13,
                                                  high_level_requirement_associations: HighLevelRequirement.find_by(full_id: 'HLR-003').try(:id),
                                                  low_level_requirement_associations:  LowLevelRequirement.find_by(full_id: 'LLR-003').try(:id),
                                                  soft_delete:                         false,
                                                  project_id:                          Project.find_by(identifier: 'TEST').try(:id),
                                                  item_id:                             Item.find_by(identifier: 'SOFTWARE_ITEM').try(:id),
                                                  organization:                        @hardware_mds_005.organization
                                               })

    assert_not_equals_nil(module_description.save, 'Module Description Record', '    Expect Module Description Record to be created. It was.')
    STDERR.puts('    A Module Description was successfully created.')
  end

  test 'should update Module Description' do
    STDERR.puts('    Check to see that a Module Description can be updated.')

    full_id                    = @hardware_mds_005.full_id.dup
    @hardware_mds_005.full_id += 'MD-003'

    assert_not_equals_nil(@hardware_mds_005.save, 'Module Description Record', '    Expect Module Description Record to be updated. It was.')

    @hardware_mds_005.full_id  = full_id
    STDERR.puts('    A Module Description was successfully updated.')
  end

  test 'should delete Module Description' do
    STDERR.puts('    Check to see that a Module Description can be deleted.')
    assert(@hardware_mds_005.destroy)
    STDERR.puts('    A Module Description was successfully deleted.')
  end

  test 'should create Module Description with undo/redo' do
    STDERR.puts('    Check to see that a Module Description can be created, then undone and then redone.')

    module_description = ModuleDescription.new({
                                                  module_description_number:           3,
                                                  full_id:                             'MD-003',
                                                  description:                         'Safety.',
                                                  file_name:                           'alert_overpressure.c' ,
                                                  version:                             1,
                                                  draft_revision:                      1.0,
                                                  revision_date:                       Date.today(),
                                                  high_level_requirement_associations: HighLevelRequirement.find_by(full_id: 'HLR-003').try(:id),
                                                  low_level_requirement_associations:  LowLevelRequirement.find_by(full_id: 'LLR-003').try(:id),
                                                  soft_delete:                         false,
                                                  project_id:                          Project.find_by(identifier: 'TEST').try(:id),
                                                  item_id:                             Item.find_by(identifier: 'SOFTWARE_ITEM').try(:id),
                                                  organization:                        @hardware_mds_005.organization
                                                })
    data_change            = DataChange.save_or_destroy_with_undo_session(module_description, 'create')

    assert_not_equals_nil(data_change, 'Module Description Record', '    Expect Module Description Record to be created. It was.')

    assert_difference('ModuleDescription.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('ModuleDescription.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Module Description was successfully created, then undone and then redone.')
  end

  test 'should update Module Description with undo/redo' do
    STDERR.puts('    Check to see that a Module Description can be updated, then undone and then redone.')

    full_id                    = @hardware_mds_005.full_id.dup
    @hardware_mds_005.full_id += '_001'
    data_change                = DataChange.save_or_destroy_with_undo_session(@hardware_mds_005, 'update')
    @hardware_mds_005.full_id  = full_id

    assert_not_equals_nil(data_change, 'Module Description Record', '    Expect Module Description Record to be updated. It was')
    assert_not_equals_nil(ModuleDescription.find_by(full_id: @hardware_mds_005.full_id + '_001', item_id: @hardware_item.id), 'Module Description Record', "    Expect Module Description Record's ID to be #{@hardware_mds_005.full_id + '_001'}. It was.")
    assert_equals(nil, ModuleDescription.find_by(full_id: @hardware_mds_005.full_id, item_id: @hardware_item.id), 'Module Description Record', '    Expect original Module Description Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, ModuleDescription.find_by(full_id: @hardware_mds_005.full_id + '_001', item_id: @hardware_item.id), 'Module Description Record', "    Expect updated Module Description's Record not to found. It was not found.")
    assert_not_equals_nil(ModuleDescription.find_by(full_id: @hardware_mds_005.full_id, item_id: @hardware_item.id), 'Module Description Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(ModuleDescription.find_by(full_id: @hardware_mds_005.full_id + '_001', item_id: @hardware_item.id), 'Module Description Record', "    Expect updated Module Description's Record to be found. It was found.")
    assert_equals(nil, ModuleDescription.find_by(full_id: @hardware_mds_005.full_id, item_id: @hardware_item.id), 'Module Description Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Module Description was successfully updated, then undone and then redone.')
  end

  test 'should delete Module Description with undo/redo' do
    STDERR.puts('    Check to see that a Module Description can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@hardware_mds_005, 'delete')

    assert_not_equals_nil(data_change, 'Module Description Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, ModuleDescription.find_by(module_description_number: @hardware_mds_005.module_description_number, item_id: @hardware_item.id), 'Module Description Record', '    Verify that the Module Description Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(ModuleDescription.find_by(module_description_number: @hardware_mds_005.module_description_number, item_id: @hardware_item.id), 'Module Description Record', '    Verify that the Module Description Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, ModuleDescription.find_by(module_description_number: @hardware_mds_005.module_description_number, item_id: @hardware_item.id), 'Module Description Record', '    Verify that the Module Description Record was deleted again after redo. It was.')
    STDERR.puts('    A Module Description was successfully deleted, then undone and then redone.')
  end

  test 'long_id should be correct' do
    STDERR.puts('    Check to see that the Module Description returns a proper Long ID.')

    @hardware_mds_005.long_id

    assert_equals('MD-006:6:HARDWARE_ITEM', @hardware_mds_005.long_id, 'Module Description Record', '    Expect long_id to be "MD-001". It was.')

    STDERR.puts('    The Module Description returns a proper Long ID successfully.')
  end

  test 'should rename prefix' do
    STDERR.puts('    Check to see that the Module Description can rename its prefix.')
    original_mds = ModuleDescription.where(item_id: @hardware_item.id)
    original_mds = original_mds.to_a.sort { |x, y| x.full_id <=> y.full_id}

    ModuleDescription.rename_prefix(@project.id, @hardware_item.id,
                                       'MD', 'Module Description')
    STDERR.puts('    The Module Description renamed its prefix successfully.')
  end

  test 'should generate XLS' do
    STDERR.puts('    Check to see that the Module Description can generate XLS properly.')

    assert_nothing_raised do
      xls = ModuleDescription.to_xls(@hardware_item.id)

      assert_not_equals_nil(xls, 'XLS Data', '    Expect XLS Data to not be nil. It was.')
    end

    STDERR.puts('    The Module Description generated XLS successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the Module Description can assign columns properly.')

    mds = ModuleDescription.new()

    assert(mds.assign_column('id', '1', @hardware_item.id))
    assert(mds.assign_column('project_id', 'Test', @hardware_item.id))
    assert_equals(@project.id, mds.project_id, 'Project ID',
                  "    Expect Project ID to be #{@project.id}. It was.")
    assert(mds.assign_column('item_id', 'HARDWARE_ITEM', @hardware_item.id))
    assert_equals(@hardware_item.id, mds.item_id, 'Item ID',
                  "    Expect Item ID to be #{@hardware_item.id}. It was.")
    assert(mds.assign_column('module_description_number', @hardware_mds_005.module_description_number.to_s,
                             @hardware_item.id))
    assert(mds.assign_column('full_id', @hardware_mds_005.full_id,
                             @hardware_item.id))
    assert_equals(@hardware_mds_005.full_id, mds.full_id, 'Full ID',
                  "    Expect Full ID to be #{@hardware_mds_005.full_id}. It was.")
    assert(mds.assign_column('description', @hardware_mds_005.description,
                             @hardware_item.id))
    assert_equals(@hardware_mds_005.description, mds.description, 'Description',
                  "    Expect Description to be #{@hardware_mds_005.description}. It was.")
    assert(mds.assign_column('version', @hardware_mds_005.version.to_s,
                             @hardware_item.id))
    assert_equals(@hardware_mds_005.version, mds.version, 'Version',
                  "    Expect Version to be #{@hardware_mds_005.version}. It was.")
    assert(mds.assign_column('created_at', @hardware_mds_005.created_at.to_s,
                             @hardware_item.id))
    assert(mds.assign_column('updated_at', @hardware_mds_005.updated_at.to_s,
                             @hardware_item.id))
    assert(mds.assign_column('organization', @hardware_mds_005.organization,
                             @hardware_item.id))
    assert(mds.assign_column('soft_delete', 'true', @hardware_item.id))
    assert_equals(true, mds.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'true' to be true. It was.")
    assert(mds.assign_column('soft_delete', 'false', @hardware_item.id))
    assert_equals(false, mds.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'false' to be false. It was.")
    assert(mds.assign_column('soft_delete', 'yes', @hardware_item.id))
    assert_equals(true, mds.soft_delete, 'Soft Delete',
                  "    Expect Soft Delete from 'yes' to be true. It was.")
    STDERR.puts('    The Module Description assigned the columns successfully.')
  end
end

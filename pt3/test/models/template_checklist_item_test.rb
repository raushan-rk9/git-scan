require 'test_helper'

class TemplateChecklistItemTest < ActiveSupport::TestCase
  def setup
    @template                     = Template.find_by(title: 'ACS DO-254 Templates')
    @template_checklist           = TemplateChecklist.find_by(title: 'Plan for Hardware Aspects of Certification')
    @template_checklist_item_001  = TemplateChecklistItem.find_by(clitemid: 1)

    user_pm
  end

  test 'Template Checklist Item record should be valid' do
    STDERR.puts('    Check to see that a Template Checklist Item Record with required fields filled in is valid.')
    assert_equals(true, @template_checklist_item_001.valid?, 'Template Checklist Item Record', '    Expect Template Checklist Recordto be valid. It was valid.')
    STDERR.puts('    The Template Checklist Item Record was valid.')
  end

  test 'Template Checklist Item record needs template_checklist_id to be valid' do
    STDERR.puts('    Check to see that a Template Checklist Item with a template checklist id is invalid.')
    @template_checklist_item_001.template_checklist_id = nil

    assert_equals(false, @template_checklist_item_001.valid?, 'Template Checklist Item Record', '    Expect Template Checklist Recordwithout template_checklist_id to be invalid. It was valid.')
    STDERR.puts('    The Template Checklist Item Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Template Checklist Item' do
    STDERR.puts('    Check to see that a Template Checklist Item can be created.')

    template_checklist_item = TemplateChecklistItem.new({
                                                           clitemid:              @template_checklist_item_001.clitemid + 20,
                                                           title:                 @template_checklist_item_001.title,
                                                           description:           @template_checklist_item_001.description,
                                                           note:                  @template_checklist_item_001.note,
                                                           template_checklist_id: @template_checklist_item_001.template_checklist_id,
                                                           reference:             @template_checklist_item_001.reference,
                                                           minimumdal:            @template_checklist_item_001.minimumdal,
                                                           supplements:           @template_checklist_item_001.supplements,
                                                           organization:          @template_checklist_item_001.organization
                                                        })

    assert_not_equals_nil(template_checklist_item.save, 'Template Checklist Item Record', '    Expect Template Checklist Item Record to be created. It was.')
    STDERR.puts('    A Template Checklist Item was successfully created.')
  end

  test 'should update Template Checklist Item' do
    STDERR.puts('    Check to see that a Template Checklist Item can be updated.')

    @template_checklist_item_001.clitemid += 20

    assert_not_equals_nil(@template_checklist_item_001.save, 'Template Checklist Item Record', '    Expect Template Checklist Item Record to be updated. It was.')
    STDERR.puts('    A Template Checklist Item was successfully updated.')
  end

  test 'should delete Template Checklist Item' do
    STDERR.puts('    Check to see that a Template Checklist Item can be deleted.')
    assert( @template_checklist_item_001.destroy)
    STDERR.puts('    A Template Checklist Item was successfully deleted.')
  end

  test 'should create Template Checklist Item with undo/redo' do
    STDERR.puts('    Check to see that a Template Checklist Item can be created, then undone and then redone.')

    template_checklist_item = TemplateChecklistItem.new({
                                                           clitemid:              @template_checklist_item_001.clitemid + 20,
                                                           title:                 @template_checklist_item_001.title,
                                                           description:           @template_checklist_item_001.description,
                                                           note:                  @template_checklist_item_001.note,
                                                           template_checklist_id: @template_checklist_item_001.template_checklist_id,
                                                           reference:             @template_checklist_item_001.reference,
                                                           minimumdal:            @template_checklist_item_001.minimumdal,
                                                           supplements:           @template_checklist_item_001.supplements,
                                                           organization:          @template_checklist_item_001.organization
                                                        })
    data_change            = DataChange.save_or_destroy_with_undo_session(template_checklist_item, 'create')

    assert_not_equals_nil(data_change, 'Template Checklist Item Record', '    Expect Template Checklist Item Record to be created. It was.')

    assert_difference('TemplateChecklistItem.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('TemplateChecklistItem.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Template Checklist Item was successfully created, then undone and then redone.')
  end

  test 'should update Template Checklist Item with undo/redo' do
    STDERR.puts('    Check to see that a Template Checklist Item can be updated, then undone and then redone.')

    @template_checklist_item_001.clitemid += 20
    data_change                        = DataChange.save_or_destroy_with_undo_session(@template_checklist_item_001, 'update')
    @template_checklist_item_001.clitemid -= 20

    assert_not_equals_nil(data_change, 'Template Checklist Item Record',
                          '    Expect Template Checklist Item Record to be updated. It was')
    assert_not_equals_nil(TemplateChecklistItem.find_by(clitemid: 21),
                          'Template Checklist Item Record',
                          "    Expect Template Checklist Item Record's ID to be 21. It was.")
    assert_equals(nil, TemplateChecklistItem.find_by(clitemid: 1),
                  'Template Checklist Item Record',
                  '    Expect original Template Checklist Item Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, TemplateChecklistItem.find_by(clitemid: 21),
                  'Template Checklist Item Record',
                  "    Expect updated Template Checklist Item's Record not to found. It was not found.")
    assert_not_equals_nil(TemplateChecklistItem.find_by(clitemid:1),
                          'Template Checklist Item Record',
                          '    Expect original Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(TemplateChecklistItem.find_by(clitemid: 21),
                          'Template Checklist Item Record',
                          "    Expect updated Template Checklist Item's Record to be found. It was found.")
    assert_equals(nil, TemplateChecklistItem.find_by(clitemid: 1),
                  'Template Checklist Item Record',
                  '    Expect original Record not to be found. It was not found.')

    STDERR.puts('    A Template Checklist Item was successfully updated, then undone and then redone.')
  end

  test 'should delete Template Checklist Item with undo/redo' do
    STDERR.puts('    Check to see that a Template Checklist Item can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@template_checklist_item_001, 'delete')

    assert_not_equals_nil(data_change, 'Template Checklist Item Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, TemplateChecklistItem.find_by(clitemid: @template_checklist_item_001.clitemid), 'Template Checklist Item Record', '    Verify that the Template Checklist Item Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(TemplateChecklistItem.find_by(clitemid: @template_checklist_item_001.clitemid), 'Template Checklist Item Record', '    Verify that the Template Checklist Item Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, TemplateChecklistItem.find_by(clitemid: @template_checklist_item_001.clitemid), 'Template Checklist Item Record', '    Verify that the Template Checklist Item Record was deleted again after redo. It was.')

    STDERR.puts('    A Template Checklist Item was successfully deleted, then undone and then redone.')
  end
end

require 'test_helper'

class ActionItemTest < ActiveSupport::TestCase
  def setup
    @project         = Project.find_by(identifier: 'TEST')
    @hardware_item   = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item   = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_ai_001 = ActionItem.find_by(actionitemid: 1,
                                          item_id:      @hardware_item.id)
    @software_ai_001 = ActionItem.find_by(actionitemid: 1,
                                          item_id:      @software_item.id)

    user_pm
  end

  test 'action item record should be valid' do
    STDERR.puts('    Check to see that a Action Item Record with require fields filled in is valid.')
    assert_equals(true, @hardware_ai_001.valid?, 'Action Item Record', '    Expect Action Item Record to be valid. It was valid.')
    STDERR.puts('    The Action Item Record was valid.')
  end

  test 'review id shall be present for action review' do
    STDERR.puts('    Check to see that a Action Item Record without a Review ID is invalid.')

    @hardware_ai_001.review_id = nil

    assert_equals(false, @hardware_ai_001.valid?, 'Action Review Record', '    Expect Action Review without review_id not to be valid. It was not valid.')
    STDERR.puts('    The Action Item Record without a Review ID  was invalid.')
  end

  test 'project id shall be present for action project' do
    STDERR.puts('    Check to see that a Action Item Record without a Project ID is invalid.')

    @hardware_ai_001.project_id = nil

    assert_equals(false, @hardware_ai_001.valid?, 'Action Project Record', '    Expect Action Project without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Action Item Record without a Project ID  was invalid.')
  end

  test 'item id shall be present for action item' do
    STDERR.puts('    Check to see that a Action Item Record without an Item ID is invalid.')

    @hardware_ai_001.item_id = nil

    assert_equals(false, @hardware_ai_001.valid?, 'Action Item Record', '    Expect Action Item without item_id not to be valid. It was not valid.')
    STDERR.puts('    The Action Item Record without an Item ID  was invalid.')
  end

  test 'description shall be present for action item' do
    STDERR.puts('    Check to see that a Action Item Record without a Description is invalid.')
    @hardware_ai_001.description = nil

    assert_equals(false, @hardware_ai_001.valid?, 'Action Item Record', '    Expect Action Item without description not to be valid. It was not valid.')
    STDERR.puts('    The Action Item Record without a Description was invalid.')
  end
# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create action item' do
    STDERR.puts('    Check to see that an Action Item can be created.')
    action_item = ActionItem.new({
                                   actionitemid: @hardware_ai_001.actionitemid,
                                   description:  @hardware_ai_001.description,
                                   openedby:     @hardware_ai_001.openedby,
                                   assignedto:   @hardware_ai_001.assignedto,
                                   status:       @hardware_ai_001.status,
                                   note:         @hardware_ai_001.note,
                                   project_id:   @hardware_ai_001.project_id,
                                   item_id:      @hardware_ai_001.item_id,
                                   review_id:    @hardware_ai_001.review_id
                                 })

    assert_not_equals_nil(action_item.save, 'Action Item Record', '    Expect Action Item Record to be created. It was.')
    STDERR.puts('    An Action Item was successfully created.')
  end

  test 'should update Action Item' do
    STDERR.puts('    Check to see that an Action Item can be updated.')

    @hardware_ai_001.actionitemid += 1

    assert_not_equals_nil(@hardware_ai_001.save, 'Action Item Record', '    Expect Action Item Record to be updated. It was.')
    STDERR.puts('    An Action Item was successfully updated.')
  end

  test 'should delete Action Item' do
    STDERR.puts('    Check to see that an Action Item can be deleted.')
    assert( @hardware_ai_001.destroy)
    STDERR.puts('    An Action Item was successfully deleted.')
  end

  test 'should create Action Item with undo/redo' do
    STDERR.puts('    Check to see that an Action Item can be created, then undone and then redone.')
    action_item = ActionItem.new({
                                   actionitemid: @hardware_ai_001.actionitemid + 1,
                                   description:  @hardware_ai_001.description,
                                   openedby:     @hardware_ai_001.openedby,
                                   assignedto:   @hardware_ai_001.assignedto,
                                   status:       @hardware_ai_001.status,
                                   note:         @hardware_ai_001.note,
                                   project_id:   @hardware_ai_001.project_id,
                                   item_id:      @hardware_ai_001.item_id,
                                   review_id:    @hardware_ai_001.review_id
                                 })
    data_change            = DataChange.save_or_destroy_with_undo_session(action_item, 'create')

    assert_not_equals_nil(data_change, 'Action Item Record', '    Expect Action Item Record to be created. It was.')

    assert_difference('ActionItem.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('ActionItem.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    An Action Item was successfully created, then undone and then redone.')
  end

  test 'should update Action Item with undo/redo' do
    STDERR.puts('    Check to see that an Action Item can be updated, then undone and then redone.')
    @hardware_ai_001.actionitemid += 1
    data_change                    = DataChange.save_or_destroy_with_undo_session(@hardware_ai_001, 'update')
    @hardware_ai_001.actionitemid -= 1

    assert_not_equals_nil(data_change, 'Action Item Record', '    Expect Action Item Record to be updated. It was')
    assert_not_equals_nil(ActionItem.find_by(actionitemid: @hardware_ai_001.actionitemid + 1, item_id: @hardware_item.id), 'Action Item Record', "    Expect Action Item Record's ID to be #{@hardware_ai_001.actionitemid + 1}. It was.")
    assert_equals(nil, ActionItem.find_by(actionitemid: @hardware_ai_001.actionitemid, item_id: @hardware_item.id), 'Action Item Record', '    Expect original Action Item Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, ActionItem.find_by(actionitemid: @hardware_ai_001.actionitemid + 1, item_id: @hardware_item.id), 'Action Item Record', "    Expect updated Action Item's Record not to found. It was not found.")
    assert_not_equals_nil(ActionItem.find_by(actionitemid: @hardware_ai_001.actionitemid, item_id: @hardware_item.id), 'Action Item Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(ActionItem.find_by(actionitemid: @hardware_ai_001.actionitemid + 1, item_id: @hardware_item.id), 'Action Item Record', "    Expect updated Action Item's Record to be found. It was found.")
    assert_equals(nil, ActionItem.find_by(actionitemid: @hardware_ai_001.actionitemid, item_id: @hardware_item.id), 'Action Item Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    An Action Item was successfully updated, then undone and then redone.')
  end

  test 'should delete Action Item with undo/redo' do
    STDERR.puts('    Check to see that an Action Item can be deleted, then undone and then redone.')
    data_change = DataChange.save_or_destroy_with_undo_session(@hardware_ai_001, 'delete')

    assert_not_equals_nil(data_change, 'Action Item Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, ActionItem.find_by(actionitemid: @hardware_ai_001.actionitemid, item_id: @hardware_item.id), 'Action Item Record', '    Verify that the Action Item Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(ActionItem.find_by(actionitemid: @hardware_ai_001.actionitemid, item_id: @hardware_item.id), 'Action Item Record', '    Verify that the Action Item Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, ActionItem.find_by(actionitemid: @hardware_ai_001.actionitemid, item_id: @hardware_item.id), 'Action Item Record', '    Verify that the Action Item Record was deleted again after redo. It was.')
    STDERR.puts('    An Action Item was successfully deleted, then undone and then redone.')
  end

  test 'isclosed should return the correct response' do
    STDERR.puts('    Check to see that an Action Item returns the proper closed status.')
    assert(!@hardware_ai_001.isclosed)
    assert(@software_ai_001.isclosed)
    STDERR.puts('    The Action Item returned the proper closed status.')
  end
end

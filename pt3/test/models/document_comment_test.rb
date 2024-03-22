require 'test_helper'

class DocumentCommentTest < ActiveSupport::TestCase
  def setup
    @project         = Project.find_by(identifier: 'TEST')
    @hardware_item   = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item   = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_dc_001 = DocumentComment.find_by(commentid: 1,
                                               item_id:   @hardware_item.id)
    @software_dc_001 = DocumentComment.find_by(commentid: 2,
                                               item_id:   @software_item.id)

    user_pm
  end

  test 'document comment record should be valid' do
    STDERR.puts('    Check to see that a Document Comment Record with required fields filled in is valid.')
    assert_equals(true, @hardware_dc_001.valid?, 'Document Comment Record',
                  '    Expect Document Comment Record to be valid. It was valid.')
    STDERR.puts('    The Document Comment Record was valid.')
  end

  test 'comment id shall be present for document comment' do
    STDERR.puts('    Check to see that a document Comment Record without a Comment ID is invalid.')

    @hardware_dc_001.commentid = nil

    assert_equals(false, @hardware_dc_001.valid?, 'Document Record',
                  '    Expect Document without comment not to be valid. It was not valid.')
    STDERR.puts('    The Document Comment Record was invalid.')
  end

  test 'project id shall be present for document comment' do
    STDERR.puts('    Check to see that a document Comment Record without a Project ID is invalid.')

    @hardware_dc_001.project_id = nil

    assert_equals(false, @hardware_dc_001.valid?, 'Project Record',
                  '    Expect Project without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Document Comment Record was invalid.')
  end

  test 'item id shall be present for document comment' do
    STDERR.puts('    Check to see that a document Comment Record without an Item ID is invalid.')

    @hardware_dc_001.item_id = nil

    assert_equals(false, @hardware_dc_001.valid?, 'Document Comment Record',
                  '    Expect Document Comment without item_id not to be valid. It was not valid.')
    STDERR.puts('    The Document Comment Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create document comment' do
    STDERR.puts('    Check to see that an Document Comment can be created.')

    document_comment = DocumentComment.new({
                                             commentid:      @hardware_dc_001.commentid + 2,
                                             document_id:    @hardware_dc_001.document_id,
                                             project_id:     @hardware_dc_001.project_id,
                                             item_id:        @hardware_dc_001.item_id,
                                             comment:        @hardware_dc_001.comment,
                                             docrevision:    @hardware_dc_001.docrevision,
                                             datemodified:   @hardware_dc_001.datemodified,
                                             status:         @hardware_dc_001.status,
                                             requestedby:    @hardware_dc_001.requestedby,
                                             assignedto:     @hardware_dc_001.assignedto,
                                             organization:   @hardware_dc_001organization,
                                             draft_revision: @hardware_dc_001.draft_revision 
                                           })

    assert_not_equals_nil(document_comment.save,
                          'Document Comment Record',
                          '    Expect Document Comment Record to be created. It was.')
    STDERR.puts('    A Document Comment was successfully created.')
  end

  test 'should update Document Comment' do
    STDERR.puts('    Check to see that an Document Comment can be updated.')

    @hardware_dc_001.commentid += 2

    assert_not_equals_nil(@hardware_dc_001.save, 'Document Comment Record',
                          '    Expect Document Comment Record to be updated. It was.')
    STDERR.puts('    A Document Comment was successfully updated.')
  end

  test 'should delete Document Comment' do
    STDERR.puts('    Check to see that an Document Comment can be deleted.')
    assert( @hardware_dc_001.destroy)
    STDERR.puts('    A Document Comment was successfully deleted.')
  end

  test 'should create Document Comment with undo/redo' do
    STDERR.puts('    Check to see that an Document Comment can be created, then undone and then redone.')

    document_comment = DocumentComment.new({
                                             commentid:      @hardware_dc_001.commentid + 2,
                                             document_id:    @hardware_dc_001.document_id,
                                             project_id:     @hardware_dc_001.project_id,
                                             item_id:        @hardware_dc_001.item_id,
                                             comment:        @hardware_dc_001.comment,
                                             docrevision:    @hardware_dc_001.docrevision,
                                             datemodified:   @hardware_dc_001.datemodified,
                                             status:         @hardware_dc_001.status,
                                             requestedby:    @hardware_dc_001.requestedby,
                                             assignedto:     @hardware_dc_001.assignedto,
                                             organization:   @hardware_dc_001organization,
                                             draft_revision: @hardware_dc_001.draft_revision 
                                           })
    data_change      = DataChange.save_or_destroy_with_undo_session(document_comment,
                                                                    'create')

    assert_not_equals_nil(data_change, 'Document Comment Record',
                          '    Expect Document Comment Record to be created. It was.')

    assert_difference('DocumentComment.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('DocumentComment.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Document Comment was successfully created, then undone and then redone.')
  end

  test 'should update Document Comment with undo/redo' do
    STDERR.puts('    Check to see that an Document Comment can be updated, then undone and then redone.')

    @hardware_dc_001.commentid += 2
    data_change                 = DataChange.save_or_destroy_with_undo_session(@hardware_dc_001, 'update')
    @hardware_dc_001.commentid -= 2

    assert_not_equals_nil(data_change, 'Action Item Record', '    Expect Action Item Record to be updated. It was')
    assert_not_equals_nil(DocumentComment.find_by(commentid: @hardware_dc_001.commentid + 2, item_id: @hardware_item.id), 'Action Item Record', "    Expect Action Item Record's ID to be #{@hardware_dc_001.commentid + 2}. It was.")
    assert_equals(nil, DocumentComment.find_by(commentid: @hardware_dc_001.commentid, item_id: @hardware_item.id), 'Action Item Record', '    Expect original Action Item Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, DocumentComment.find_by(commentid: @hardware_dc_001.commentid + 2, item_id: @hardware_item.id), 'Action Item Record', "    Expect updated Action Item's Record not to found. It was not found.")
    assert_not_equals_nil(DocumentComment.find_by(commentid: @hardware_dc_001.commentid, item_id: @hardware_item.id), 'Action Item Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(DocumentComment.find_by(commentid: @hardware_dc_001.commentid + 2, item_id: @hardware_item.id), 'Action Item Record', "    Expect updated Action Item's Record to be found. It was found.")
    assert_equals(nil, DocumentComment.find_by(commentid: @hardware_dc_001.commentid, item_id: @hardware_item.id), 'Action Item Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Document Comment was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete Document Comment" do
    STDERR.puts('    Check to see that a Document Comment can be deleted undone and redone.')

    data_change   = nil

    assert_difference('DocumentComment.count', -1) do
      data_change = DataChange.save_or_destroy_with_undo_session(@hardware_dc_001,
                                                                 'delete')
    end

    assert_not_nil(data_change)

    assert_difference('DocumentComment.count', +1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('DocumentComment.count', -1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Project was successfully deleted undone and redone.')
  end
end

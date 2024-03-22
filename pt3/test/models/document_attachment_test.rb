require 'test_helper'

class DocumentAttachmentTest < ActiveSupport::TestCase
  def setup
    @project         = Project.find_by(identifier: 'TEST')
    @hardware_item   = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item   = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_da_001 = DocumentAttachment.find_by(id:      1,
                                                  item_id: @hardware_item.id)
    @software_da_001 = DocumentAttachment.find_by(id:      2,
                                                  item_id: @software_item.id)

    user_pm
  end

  test 'document attachment record should be valid' do
    STDERR.puts('    Check to see that a Document Attachment Record with required fields filled in is valid.')
    assert_equals(true, @hardware_da_001.valid?, 'Document Attachment Record',
                  '    Expect Document Attachment Record to be valid. It was valid.')
    STDERR.puts('    The Document Attachment Record was valid.')
  end

  test 'document id shall be present for document attachment' do
    STDERR.puts('    Check to see that a document Attachment Record without a Document ID is invalid.')

    @hardware_da_001.document_id = nil

    assert_equals(false, @hardware_da_001.valid?, 'Document Record',
                  '    Expect Document without document_id not to be valid. It was not valid.')
    STDERR.puts('    The Document Attachment Record was invalid.')
  end

  test 'project id shall be present for document attchment' do
    STDERR.puts('    Check to see that a document Attachment Record without a Project ID is invalid.')

    @hardware_da_001.project_id = nil

    assert_equals(false, @hardware_da_001.valid?, 'Project Record',
                  '    Expect Document Attachment without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Document Attachment Record was invalid.')
  end

  test 'item id shall be present for document attachment' do
    STDERR.puts('    Check to see that a document Attachment Record without an Item ID is invalid.')

    @hardware_da_001.item_id = nil

    assert_equals(false, @hardware_da_001.valid?, 'Document Attachment Record',
                  '    Expect Document Attachment without item_id not to be valid. It was not valid.')
    STDERR.puts('    The Document Attachment Record was invalid.')
  end

  test 'user shall be present for document attachment' do
    STDERR.puts('    Check to see that a document Attachment Record without a User is invalid.')

    @hardware_da_001.user = nil

    assert_equals(false, @hardware_da_001.valid?, 'Document Attachment Record',
                  '    Expect Document Attachment without user not to be valid. It was not valid.')
    STDERR.puts('    The Document Attachment Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create document attachment' do
    STDERR.puts('    Check to see that an Document Attachment can be created.')

    document_attachment = DocumentAttachment.new({
                                   id:           @hardware_da_001.id + 2,
                                   document_id:  @hardware_da_001.document_id,
                                   project_id:   @hardware_da_001.project_id,
                                   item_id:      @hardware_da_001.item_id,
                                   user:         @hardware_da_001.user,
                                   upload_date:  @hardware_da_001.upload_date
                                 })

    assert_not_equals_nil(document_attachment.save,
                          'Document Attachment Record',
                          '    Expect Document Attachment Record to be created. It was.')
    STDERR.puts('    A Document Attachment was successfully created.')
  end

  test 'should update Document Attachment' do
    STDERR.puts('    Check to see that an Document Attachment can be updated.')

    @hardware_da_001.id += 2

    assert_not_equals_nil(@hardware_da_001.save, 'Document Attachment Record',
                          '    Expect Document Attachment Record to be updated. It was.')
    STDERR.puts('    A Document Attachment was successfully updated.')
  end

  test 'should delete Document Attachment' do
    STDERR.puts('    Check to see that an Document Attachment can be deleted.')
    assert( @hardware_da_001.destroy)
    STDERR.puts('    A Document Attachment was successfully deleted.')
  end

  test 'should create Document Attachment with undo/redo' do
    STDERR.puts('    Check to see that an Document Attachment can be created, then undone and then redone.')

    document_attachment = DocumentAttachment.new({
                                   id:           @hardware_da_001.id + 2,
                                   document_id:  @hardware_da_001.document_id,
                                   project_id:   @hardware_da_001.project_id,
                                   item_id:      @hardware_da_001.item_id,
                                   user:         @hardware_da_001.user,
                                   upload_date:  @hardware_da_001.upload_date
                                 })
    data_change            = DataChange.save_or_destroy_with_undo_session(document_attachment, 'create')

    assert_not_equals_nil(data_change, 'Document Attachment Record', '    Expect Document Attachment Record to be created. It was.')

    assert_difference('DocumentAttachment.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('DocumentAttachment.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Document Attachment was successfully created, then undone and then redone.')
  end

  test 'should update Document Attachment with undo/redo' do
    STDERR.puts('    Check to see that an Document Attachment can be updated, then undone and then redone.')

    @hardware_da_001.user = 'test_4@airworthinesscert.com'
    data_change           = DataChange.save_or_destroy_with_undo_session(@hardware_da_001, 'update')
    @hardware_da_001.user = 'test_3@airworthinesscert.com'

    assert_not_equals_nil(data_change, 'Document Attachment Record', '    Expect Document Attachment Record to be updated. It was')
    assert_not_equals_nil(DocumentAttachment.find_by(user: 'test_4@airworthinesscert.com' , item_id: @hardware_item.id), 'Document Attachment Record', "    Expect Document Attachment Record's ID to be #{'test_4@airworthinesscert.com' }. It was.")
    assert_equals(nil, DocumentAttachment.find_by(user: 'test_3@airworthinesscert.com', item_id: @hardware_item.id), 'Document Attachment Record', '    Expect original Document Attachment Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, DocumentAttachment.find_by(user: 'test_4@airworthinesscert.com' , item_id: @hardware_item.id), 'Document Attachment Record', "    Expect updated Document Attachment's Record not to found. It was not found.")
    assert_not_equals_nil(DocumentAttachment.find_by(user: 'test_3@airworthinesscert.com', item_id: @hardware_item.id), 'Document Attachment Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(DocumentAttachment.find_by(user: 'test_4@airworthinesscert.com' , item_id: @hardware_item.id), 'Document Attachment Record', "    Expect updated Document Attachment's Record to be found. It was found.")
    assert_equals(nil, DocumentAttachment.find_by(user: 'test_3@airworthinesscert.com', item_id: @hardware_item.id), 'Document Attachment Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Document Attachment was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete Document Attachment" do
    STDERR.puts('    Check to see that a Document Attachment can be deleted undone and redone.')

    data_change   = nil

    assert_difference('DocumentAttachment.count', -1) do
      data_change = DataChange.save_or_destroy_with_undo_session(@hardware_da_001,
                                                                 'delete')
    end

    assert_not_nil(data_change)

    assert_difference('DocumentAttachment.count', +1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('DocumentAttachment.count', -1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Document Attachment was successfully deleted undone and redone.')
  end
end

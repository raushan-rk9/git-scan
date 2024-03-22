require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  setup do
    @document   = Document.find_by(docid: 'PHAC')
    @project    = Project.find_by(identifier: 'TEST')
    @item       = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @model_file = ModelFile.find_by(full_id: 'MF-001')
    @file_data  = Rack::Test::UploadedFile.new('test/fixtures/files/PSAC.doc',
                                               'application/msword',
                                               true)

    user_pm
  end

  test 'document record should be valid' do
    STDERR.puts('    Check to see that a Document Record with required fields filled in is valid.')
    assert_equals(true, @document.valid?, 'Document Record',
                  '    Expect Document Record to be valid. It was valid.')
    STDERR.puts('    The Document Record was valid.')
  end

  test 'project id shall be present for document ' do
    STDERR.puts('    Check to see that a Document Record without a Project ID is invalid.')

    @document.project_id = nil

    assert_equals(false, @document.valid?, 'Project Record',
                  '    Expect Document without a project_id not to be valid. It was not valid.')
    STDERR.puts('    The Document Record was invalid.')
  end

  test 'item id shall be present for document ' do
    STDERR.puts('    Check to see that a document Record without an Item ID is invalid.')

    @document.item_id = nil

    assert_equals(false, @document.valid?, 'Document Record',
                  '    Expect Document without an item_id not to be valid. It was not valid.')
    STDERR.puts('    The Document Record was invalid.')
  end

  test 'docid shall be present for document ' do
    STDERR.puts('    Check to see that a document Record without a Doc ID is invalid.')

    @document.docid = nil

    assert_equals(false, @document.valid?, 'Document Record',
                  '    Expect Document without a Doc ID not to be valid. It was not valid.')
    STDERR.puts('    The Document Record was invalid.')
  end

  test 'name shall be present for document ' do
    STDERR.puts('    Check to see that a document Record without a Name is invalid.')

    @document.name = nil

    assert_equals(false, @document.valid?, 'Document Record',
                  '    Expect Document without a Name not to be valid. It was not valid.')
    STDERR.puts('    The Document Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test "Create Document" do
    STDERR.puts('    Check to see that an Document can be created.')

    document = Document.new({
                              docid:            @document.docid,
                              name:             @document.name,
                              category:         @document.category,
                              version:          @document.version,
                              item_id:          @document.item_id,
                              project_id:       @document.project_id,
                              draft_revision:   @document.draft_revision,
                              doccomment_count: @document.doccomment_count,
                              document_type:    @document.document_type,
                              file_path:        @document.file_path,
                              file_type:        @document.file_type,
                              upload_date:      @document.upload_date
                            })

    assert_not_equals_nil(document.save, 'Docment Record', '    Expect Document Record to be created. It was.')
    STDERR.puts('    A Document was successfully created.')
  end

  test "Update Document" do
    STDERR.puts('    Check to see that an Document  can be updated.')

    doc_id           = @document.docid.dup
    @document.docid += "_001"

    assert_not_equals_nil(@document.save, 'Docment Record', '    Expect Document Record to be updated. It was.')

    @document.docid  = doc_id
    STDERR.puts('    A Document was successfully updated.')
  end

  test "Delete Document" do
    STDERR.puts('    Check to see that an Document  can be deleted.')
    assert(@document.destroy)
    STDERR.puts('    A Document  was successfully deleted.')
  end

  test "Undo/Redo Create Document" do
    STDERR.puts('    Check to see that an Document can be created, then undone and then redone.')

    document = Document.new({
                              docid:            @document.docid,
                              name:             @document.name,
                              category:         @document.category,
                              version:          @document.version,
                              item_id:          @document.item_id,
                              project_id:       @document.project_id,
                              draft_revision:   @document.draft_revision,
                              doccomment_count: @document.doccomment_count,
                              document_type:    @document.document_type,
                              file_path:        @document.file_path,
                              file_type:        @document.file_type,
                              upload_date:      @document.upload_date
                            })
    data_change    = DataChange.save_or_destroy_with_undo_session(document, 'create')

    assert_not_equals_nil(data_change, 'Document Record', '    Expect Document Record to be created. It was.')

    assert_difference('Document.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('Document.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Document was successfully created, then undone and then redone.')
  end

  test "Undo/Redo Update Document" do
    STDERR.puts('    Check to see that an Document can be updated, then undone and then redone.')

    doc_id           = @document.docid.dup
    @document.docid += '_001'
    data_change      = DataChange.save_or_destroy_with_undo_session(@document, 'update')
    @document.docid  = doc_id

    assert_not_equals_nil(data_change, 'Document Record', '    Expect Document Record to be updated. It was')
    assert_not_equals_nil(Document.find_by(docid: @document.docid + "_001"), 'Document Record', "    Expect Document Record's ID to be #{@document.docid + '_001'}. It was.")
    assert_equals(nil, Document.find_by(docid: @document.docid), 'Document Record', '    Expect original Document Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, Document.find_by(docid: @document.docid + '_001'), 'Document Record', "    Expect updated Document's Record not to found. It was not found.")
    assert_not_equals_nil(Document.find_by(docid: @document.docid), 'Document Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(Document.find_by(docid: @document.docid + '_001'), 'Document Record', "    Expect updated Document's Record to be found. It was found.")
    assert_equals(nil, Document.find_by(docid: @document.docid), 'Document Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Document  was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete Document" do
    STDERR.puts('    Check to see that a Document Attachment can be deleted undone and redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@document, 'delete')

    assert_not_equals_nil(data_change, 'Document Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, Document.find_by(docid: @document.docid), 'Document Record', '    Verify that the Document Record was actually deleted. It was.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(Document.find_by(docid: @document.docid), 'Document Record', '    Verify that the Document Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, Document.find_by(docid: @document.docid), 'Document Record', '    Verify that the Document Record was deleted again after redo. It was.')

    STDERR.puts('    A Document Attachment was successfully deleted undone and redone.')
  end

  test "Document.id_from_docid(id)" do
    STDERR.puts('    Check to see that an Document returns the ID from a Doc ID.')
    assert_equals(@document.id, Document.id_from_docid(@document.docid), 'Document ID')
    STDERR.puts('    The Document returned the ID from a Doc ID successfully.')
  end

  test "Document.id_from_name(id)" do
    STDERR.puts('    Check to see that an Document returns the ID from a name.')
    assert_equals('PHAC', Document.id_from_name(@document.id), 'Document ID')
    assert_equals('PHAC', Document.id_from_name(@document.id.to_s), 'Document ID')
    assert_equals('PHAC', Document.id_from_name('PHAC.doc'), 'Document Name')
    STDERR.puts('    The Document returned the ID from a name successfully.')
  end

  test "Document.docid_from_id(id)" do
    STDERR.puts('    Check to see that an Document returns the Doc ID from an ID.')
    assert_equals('PHAC', Document.docid_from_id(@document.id), 'Document ID')
    STDERR.puts('    The Document returned the Doc ID from an ID successfully.')
  end

  test "Document.name_from_id(id)" do
    STDERR.puts('    Check to see that an Document returns the Name from an ID.')
    assert_equals('PHAC.doc', Document.name_from_id(@document.id), 'Document ID')
    STDERR.puts('    The Document returned the Name from an ID successfully.')
  end

  test "get_tree" do
    STDERR.puts('    Check to see that an Document can return the root directory.')
    assert_equals('', @document.get_tree, 'Document Tree', '    Verify that the tree is empty. It was.')
    STDERR.puts('    The Document successfully returned the root directory.')
  end

  test "get_file_path" do
    STDERR.puts('    Check to see that an Document can return the file path for a document.')
    assert_equals('/var/folders/documents/test/PHAC.doc', @document.get_file_path, 'Document File Path')
    STDERR.puts('    The Document successfully returned the file path for a document.')
  end

  test "get_file_contents" do
    STDERR.puts('    Check to see that an Document can get the contents from a document.')
    assert(@document.get_file_contents)
    STDERR.puts('    The Document successfully got the contents from a document.')
  end

  test "store_file" do
    STDERR.puts('    Check to see that an Document can store a file.')
    assert_equals('/var/folders/documents/test/PSAC',
                 @document.store_file(@file_data, true, true)[0..31], 'File Name')
    STDERR.puts('    The Document successfully stored a file.')
  end

  test "replace_file" do
    STDERR.puts('    Check to see that an Document can replace a file.')
    assert(@document.replace_file(@file_data, @document.project_id,
                                  @document.item_id))
    STDERR.puts('    The Document successfully replace a file.')
  end

  test "Document.get_or_create_folder" do
    STDERR.puts('    Check to see that an Document can get or create a "folder".')
    assert(Document.get_or_create_folder('test', @project.id, @item.id))
    STDERR.puts('    The Document successfully got or created a "folder.')
  end

  test "Document.duplicate_file" do
    STDERR.puts('    Check to see that an Document can duplicate a file.')

    folder = Document.get_or_create_folder('test', @project.id, @item.id)

    assert(Document.duplicate_file(folder, 'test', @model_file))
    STDERR.puts('    The Document successfully duplicate a file.')
  end

  test "Document.add_document" do
    STDERR.puts('    Check to see that an Document can add a document.')
    assert(Document.add_document(@file_data, @project.id, @item.id))
    STDERR.puts('    The Document successfully added a document.')
  end

  test "Document.replace_document_file" do
    STDERR.puts('    Check to see that an Document can replace a document.')
    assert(Document.replace_document_file( @document.id, @file_data))
    STDERR.puts('    The Document successfully replaced a document.')
  end
end

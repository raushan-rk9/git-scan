require 'test_helper'

class TemplateDocumentTest < ActiveSupport::TestCase
  def setup
    @template          = Template.find_by(title: 'ACS DO-254 Templates')
    @template_document = TemplateDocument.find_by(title: 'PHAC-A')

    user_pm
  end

  test 'Template Document Record should be valid' do
    STDERR.puts('    Check to see that a Template Document Record with required fields filled in is valid.')
    assert_equals(true, @template_document.valid?, 'Template Document Record',
                  '    Expect Template Document Record to be valid. It was valid.')
    STDERR.puts('    The Template Document Record was valid.')
  end

  test 'Template Document Record needs template_id to be valid' do
    STDERR.puts('    Check to see that a Template Document with a template Document id is invalid.')
    @template_document.template_id = nil

    assert_equals(false, @template_document.valid?, 'Template Document Record',
                  '    Expect Template Document Recordwithout template_Document_id to be invalid. It was valid.')
    STDERR.puts('    The Template Document Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create Template Document' do
    STDERR.puts('    Check to see that a Template Document can be created.')
    template_Document = TemplateDocument.new({
                                                document_id:      @template_document.document_id + 1,
                                                title:            @template_document.title,
                                                description:      @template_document.description,
                                                notes:            @template_document.notes,
                                                document_class:   @template_document.document_class,
                                                document_type:    @template_document.document_type,
                                                template_id:      @template_document.template_id,
                                                organization:     @template_document.organization,
                                                docid:            @template_document.docid.sub('_C', '_A'),
                                                name:             @template_document.name,
                                                category:         @template_document.category,
                                                file_type:        @template_document.file_type,
                                                dal:              'A',
                                                version:          @template_document.version,
                                                source:           @template_document.source,
                                                draft_revision:   @template_document.draft_revision,
                                                upload_date:      @template_document.upload_date 
                                             })

    assert_not_equals_nil(template_Document.save, 'Template Document Record',
                          '    Expect Template Document Record to be created. It was.')
    STDERR.puts('    A Template Document was successfully created.')
  end

  test 'should update Template Document' do
    STDERR.puts('    Check to see that a Template Document can be updated.')

    @template_document.docid.gsub!('_C', '_A')

    @template_document.dal = 'A'

    assert_not_equals_nil(@template_document.save, 'Template Document Record',
                          '    Expect Template Document Record to be updated. It was.')
    STDERR.puts('    A Template Document was successfully updated.')
  end

  test 'should delete Template Document' do
    STDERR.puts('    Check to see that a Template Document can be deleted.')
    assert(@template_document.destroy)
    STDERR.puts('    A Template Document was successfully deleted.')
  end

  test 'should create Template Document with undo/redo' do
    STDERR.puts('    Check to see that a Template Document can be created, then undone and then redone.')

    template_Document = TemplateDocument.new({
                                                document_id:      @template_document.document_id + 1,
                                                title:            @template_document.title,
                                                description:      @template_document.description,
                                                notes:            @template_document.notes,
                                                document_class:   @template_document.document_class,
                                                document_type:    @template_document.document_type,
                                                template_id:      @template_document.template_id,
                                                organization:     @template_document.organization,
                                                docid:            @template_document.docid.sub('_C', '_A'),
                                                name:             @template_document.name,
                                                category:         @template_document.category,
                                                file_type:        @template_document.file_type,
                                                dal:              'A',
                                                version:          @template_document.version,
                                                source:           @template_document.source,
                                                draft_revision:   @template_document.draft_revision,
                                                upload_date:      @template_document.upload_date 
                                             })
    data_change       = DataChange.save_or_destroy_with_undo_session(template_Document,
                                                                    'create')

    assert_not_equals_nil(data_change, 'Template Document Record',
                          '    Expect Template Document Record to be created. It was.')

    assert_difference('TemplateDocument.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('TemplateDocument.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Template Document was successfully created, then undone and then redone.')
  end

  test 'should update Template Document with undo/redo' do
    STDERR.puts('    Check to see that a Template Document can be updated, then undone and then redone.')

    @template_document.document_id += 1
    data_change                     = DataChange.save_or_destroy_with_undo_session(@template_document, 'update')
    @template_document.document_id -= 1

    assert_not_equals_nil(data_change, 'Template Document Record',
                          '    Expect Template Document Record to be updated. It was')
    assert_not_equals_nil(TemplateDocument.find_by(document_id: 2),
                          'Template Document Record',
                          "    Expect Template Document Record's ID to be 2. It was.")
    assert_equals(nil, TemplateDocument.find_by(document_id: 1),
                  'Template Document Record',
                  '    Expect original Template Document Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, TemplateDocument.find_by(document_id: 2),
                  'Template Document Record',
                  "    Expect updated Template Document's Record not to found. It was not found.")
    assert_not_equals_nil(TemplateDocument.find_by(document_id: 1),
                          'Template Document Record',
                          '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(TemplateDocument.find_by(document_id: 2),
                          'Template Document Record',
                          "    Expect updated Template Document's Record to be found. It was found.")
    assert_equals(nil, TemplateDocument.find_by(document_id: 1),
                  'Template Document Record',
                  '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Template Document was successfully updated, then undone and then redone.')
  end

  test 'should delete Template Document with undo/redo' do
    STDERR.puts('    Check to see that a Template Document can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@template_document,
                                                               'delete')

    assert_not_equals_nil(data_change, 'Template Document Record',
                          '    Expect that the delete succeeded. It did.')
    assert_equals(nil, TemplateDocument.find_by(document_id: @template_document.document_id),
                  'Template Document Record',
                  '    Verify that the Template Document Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(TemplateDocument.find_by(document_id: @template_document.document_id), 'Template Document Record', '    Verify that the Template Document Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, TemplateDocument.find_by(document_id: @template_document.document_id),
                  'Template Document Record',
                  '    Verify that the Template Document Record was deleted again after redo. It was.')
    STDERR.puts('    A Template Document was successfully deleted, then undone and then redone.')
  end
end

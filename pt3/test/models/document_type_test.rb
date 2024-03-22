require 'test_helper'

class DocumentTypeTest < ActiveSupport::TestCase
  def setup
    @hardware_dt_001 = DocumentType.find_by(document_code: 'HAS',
                                            description:   'Hardware Accomplishment Summary',
                                            dal_levels:    [ 'A' ])
    @software_dt_001 = DocumentType.find_by(document_code: 'HAS',
                                            description:   'Hardware Accomplishment Summary',
                                            dal_levels:    [ 'B' ])

    user_pm
  end

  test 'document type record should be valid' do
    STDERR.puts('    Check to see that a Document Type Record with required fields filled in is valid.')
    assert_equals(true, @hardware_dt_001.valid?, 'Document Type Record',
                  '    Expect Document Type Record to be valid. It was valid.')
    STDERR.puts('    The Document Type Record was valid.')
  end

  test 'document code shall be present for document attchment' do
    STDERR.puts('    Check to see that a document Type Record without a Document Code is invalid.')

    @hardware_dt_001.document_code = nil

    assert_equals(false, @hardware_dt_001.valid?, 'Document Record',
                  '    Expect Document without document_code not to be valid. It was not valid.')
    STDERR.puts('    The Document Type Record was invalid.')
  end

  test 'description shall be present for document type' do
    STDERR.puts('    Check to see that a document Type Record without a Description is invalid.')

    @hardware_dt_001.description = nil

    assert_equals(false, @hardware_dt_001.valid?, 'Document Type Record',
                  '    Expect Document Type without description not to be valid. It was not valid.')
    STDERR.puts('    The Document Type Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create document type' do
    STDERR.puts('    Check to see that an Document Type can be created.')

    document_type = DocumentType.new({
                                   document_code:    'XYZ',
                                   description:      @hardware_dt_001.description,
                                   item_types:       @hardware_dt_001.item_types,
                                   dal_levels:       @hardware_dt_001.dal_levels,
                                   control_category: @hardware_dt_001.control_category
                                 })

    assert_not_equals_nil(document_type.save,
                          'Document Type Record',
                          '    Expect Document Type Record to be created. It was.')
    STDERR.puts('    A Document Type was successfully created.')
  end

  test 'should update Document Type' do
    STDERR.puts('    Check to see that an Document Type can be updated.')

    @hardware_dt_001.id += 2

    assert_not_equals_nil(@hardware_dt_001.save, 'Document Type Record',
                          '    Expect Document Type Record to be updated. It was.')
    STDERR.puts('    A Document Type was successfully updated.')
  end

  test 'should delete Document Type' do
    STDERR.puts('    Check to see that an Document Type can be deleted.')
    assert( @hardware_dt_001.destroy)
    STDERR.puts('    A Document Type was successfully deleted.')
  end

  test 'should create Document Type with undo/redo' do
    STDERR.puts('    Check to see that an Document Type can be created, then undone and then redone.')

    document_type = DocumentType.new({
                                        document_code:    'XYZ',
                                        description:      @hardware_dt_001.description,
                                        item_types:       @hardware_dt_001.item_types,
                                        dal_levels:       @hardware_dt_001.dal_levels,
                                        control_category: @hardware_dt_001.control_category
                                     })
    data_change            = DataChange.save_or_destroy_with_undo_session(document_type, 'create')

    assert_not_equals_nil(data_change, 'Document Type Record', '    Expect Document Type Record to be created. It was.')

    assert_difference('DocumentType.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('DocumentType.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Document Type was successfully created, then undone and then redone.')
  end

  test 'should update Document Type with undo/redo' do
    STDERR.puts('    Check to see that an Document Type can be updated, then undone and then redone.')

    @hardware_dt_001.document_code = 'XYZ'
    data_change                    = DataChange.save_or_destroy_with_undo_session(@hardware_dt_001, 'update')
    @hardware_dt_001.document_code = 'HAS'

    assert_not_equals_nil(data_change, 'Document Type Record',
                          '    Expect Document Type Record to be updated. It was')
    assert_not_equals_nil(DocumentType.find_by(document_code: 'XYZ',
                                               description:   'Hardware Accomplishment Summary',
                                               dal_levels: [  'A' ]),
                          'Document Type Record',
                          "    Expect Document Type Record's ID to be #{'HAS' }. It was.")
    assert_equals(nil, DocumentType.find_by(document_code: 'HAS',
                                            description: 'Hardware Accomplishment Summary',
                                            dal_levels: [  'A' ]),
                  'Document Type Record',
                  '    Expect original Document Type Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, DocumentType.find_by(document_code: 'XYZ',
                                            description: 'Hardware Accomplishment Summary',
                                            dal_levels: [  'A' ]),
                  'Document Type Record',
                  "    Expect updated Document Type's Record not to found. It was not found.")
    assert_not_equals_nil(DocumentType.find_by(document_code: 'HAS',
                                               description: 'Hardware Accomplishment Summary',
                                               dal_levels: [  'A' ]),
                          'Document Type Record',
                          '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(DocumentType.find_by(document_code: 'XYZ',
                                               description: 'Hardware Accomplishment Summary',
                                               dal_levels: [  'A' ]),
                          'Document Type Record',
                          "    Expect updated Document Type's Record to be found. It was found.")
    assert_equals(nil, DocumentType.find_by(document_code: 'HAS',
                                            description: 'Hardware Accomplishment Summary',
                                            dal_levels: [  'A' ]),
                  'Document Type Record',
                  '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Document Type was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete Document Type" do
    STDERR.puts('    Check to see that a Document Type can be deleted undone and redone.')

    data_change   = nil

    assert_difference('DocumentType.count', -1) do
      data_change = DataChange.save_or_destroy_with_undo_session(@hardware_dt_001,
                                                                 'delete')
    end

    assert_not_nil(data_change)

    assert_difference('DocumentType.count', +1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('DocumentType.count', -1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Document Type was successfully deleted undone and redone.')
  end
end

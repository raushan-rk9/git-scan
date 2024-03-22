require 'test_helper'

class DocumentTypesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @hardware_dt_001 = DocumentType.find_by(document_code: 'HAS',
                                            description:   'Hardware Accomplishment Summary',
                                            dal_levels:    [ 'A' ])
    @software_dt_001 = DocumentType.find_by(document_code: 'HAS',
                                            description:   'Hardware Accomplishment Summary',
                                            dal_levels:    [ 'B' ])

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Document Type List Page can be loaded.')
    get document_types_url
    assert_response :success
    STDERR.puts('    The Document Type List Page loaded successfully.')
  end

  test "should show document_type" do
    STDERR.puts('    Check to see that a new Document Type can be loaded.')
    get document_type_url(@hardware_dt_001)
    assert_response :success
    STDERR.puts('    A new Document Type Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Document Type page can be loaded.')
    get new_document_type_url
    assert_response :success
    STDERR.puts('    The new Document Type page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a edit Document Type page can be loaded.')
    get edit_document_type_url(@hardware_dt_001)
    assert_response :success
    STDERR.puts('    The edit Document Type page loaded successfully.')
  end

  test "should create document_type" do
    STDERR.puts('    Check to see that a new Document Type can be created.')
    assert_difference('DocumentType.count') do
      post document_types_url,
        params:
        {
          document_type:
          {
            document_code:    'XYZ',
            description:      'XYZ Document',
            item_types:       [ '1' ],
            dal_levels:       [ 'A' ],
            control_category: 'CC1/HC1',
            organization:     'test'
          }
        }
    end

    assert_redirected_to document_type_url(DocumentType.last)
    STDERR.puts('    A new Document Type was created successfully.')
  end

  test "should update document_type" do
    STDERR.puts('    Check to see that a new Document Type can be updated.')
    patch document_type_url(@hardware_dt_001),
      params:
      {
        document_type:
        {
          document_code:    'XYZ',
          description:      'XYZ Document',
          item_types:       [ '1' ],
          dal_levels:       [ 'A' ],
          control_category: 'CC1/HC1',
          organization:     'test'
        }
      }

    assert_redirected_to document_type_url(@hardware_dt_001)
    STDERR.puts('    A new Document Type was updated successfully.')
  end

  test "should destroy document_type" do
    STDERR.puts('    Check to see that a new Document Type can be deleted.')
    assert_difference('DocumentType.count', -1) do
      delete document_type_url(@hardware_dt_001)
    end

    assert_redirected_to document_types_url
    STDERR.puts('    A new Document Type was deleted successfully.')
  end
end

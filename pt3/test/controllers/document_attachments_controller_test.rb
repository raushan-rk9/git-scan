require 'test_helper'

class DocumentAttachmentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project           = Project.find_by(identifier: 'TEST')
    @hardware_document = Document.find_by(docid: 'PHAC')
    @software_document = Document.find_by(docid: 'PSAC')
    @hardware_da_001   = DocumentAttachment.find_by(id:          1,
                                                    document_id: @hardware_document.id)
    @software_da_001   = DocumentAttachment.find_by(id:          2,
                                                    document_id: @hardware_document.id)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Document Attachment List Page can be loaded.')
    get document_document_attachments_url(@hardware_document)
    assert_response :success
    STDERR.puts('    The Document Attachment List Page loaded successfully.')
  end

  test "should show document_attachment" do
    STDERR.puts('    Check to see that a new Document Attachment can be loaded.')
    get document_document_attachment_url(@hardware_document, @hardware_da_001)
    assert_response :success
    STDERR.puts('    A new Document Attachment Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Document Attachment page can be loaded.')
    get new_document_document_attachment_url(@hardware_document)
    assert_response :success
    STDERR.puts('    The new Document Attachment page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a edit Document Attachment page can be loaded.')
    get edit_document_document_attachment_url(@hardware_document, @hardware_da_001)
    assert_response :success
    STDERR.puts('    The eidt Document Attachment page loaded successfully.')
  end

  test "should create document_attachment" do
    STDERR.puts('    Check to see that a Document Attachment can be created.')

    assert_difference('DocumentAttachment.count') do
      post document_document_attachments_url(@hardware_document),
        params:
        {
          document_attachment:
          {
            id:           @hardware_da_001.id + 2,
            document_id:  @hardware_da_001.document_id,
            project_id:   @hardware_da_001.project_id,
            item_id:      @hardware_da_001.item_id,
            user:         @hardware_da_001.user,
            upload_date:  @hardware_da_001.upload_date
          }
        }
    end

    assert_redirected_to document_document_attachments_url(@hardware_document)
    STDERR.puts('    The Document Attachment was be created succesfully.')
  end

  test "should update document_attachment" do
    STDERR.puts('    Check to see that a Document Attachment can be updated.')

    patch document_document_attachment_url(@hardware_document, @hardware_da_001),
      params:
      {
        document_attachment:
        {
          id:           @hardware_da_001.id + 2,
          document_id:  @hardware_da_001.document_id,
          project_id:   @hardware_da_001.project_id,
          item_id:      @hardware_da_001.item_id,
          user:         @hardware_da_001.user,
          upload_date:  @hardware_da_001.upload_date
        }
      }

    assert_redirected_to document_document_attachment_url(@hardware_document, @hardware_da_001)
    STDERR.puts('    The Document Attachment was be updated succesfully.')
  end

  test "should destroy document_attachment" do
    STDERR.puts('    Check to see that a Document Attachment can be deleted.')

    assert_difference('DocumentAttachment.count', -1) do
      delete document_document_attachment_url(@hardware_document, @hardware_da_001)
    end

    assert_redirected_to document_document_attachments_url(@hardware_document)
    STDERR.puts('    The Document Attachment was be deleted succesfully.')
  end
end

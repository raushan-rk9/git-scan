require 'test_helper'

class DocumentCommentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project           = Project.find_by(identifier: 'TEST')
    @hardware_document = Document.find_by(docid: 'PHAC')
    @software_document = Document.find_by(docid: 'PSAC')
    @hardware_dc_001   = DocumentComment.find_by(commentid:   1,
                                                 document_id: @hardware_document.id)
    @software_dc_001   = DocumentComment.find_by(commentid:   2,
                                                 document_id: @software_document.id)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Document Comment List Page can be loaded.')
    get document_document_comments_url(@hardware_document)
    assert_response :success
    STDERR.puts('    The Document Comment List Page loaded successfully.')
  end

  test "should show document_comment" do
    STDERR.puts('    Check to see that a new Document Comment can be loaded.')
    get document_document_comment_url(@hardware_document, @hardware_dc_001)
    assert_response :success
    STDERR.puts('    A new Document Comment Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Document Comment page can be loaded.')
    get new_document_document_comment_url(@hardware_document)
    assert_response :success
    STDERR.puts('    The new Document Comment page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a edit Document Comment page can be loaded.')
    get edit_document_document_comment_url(@hardware_document, @hardware_dc_001)
    assert_response :success
    STDERR.puts('    The eidt Document Comment page loaded successfully.')
  end

  test "should create document_comment" do
    STDERR.puts('    Check to see that a Document Comment can be created.')

    assert_difference('DocumentComment.count') do
      post document_document_comments_url(@hardware_document),
        params:
        {
          document_comment:
          {
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
          }
        }
    end

    document_comment = DocumentComment.find_by(commentid: @hardware_dc_001.commentid + 2)

    assert document_comment
    assert_redirected_to document_document_comment_url(@hardware_document,
                                                       document_comment)
    STDERR.puts('    The Document Comment was be created succesfully.')
  end

  test "should update document_comment" do
    STDERR.puts('    Check to see that a Document Comment can be updated.')

    patch document_document_comment_url(@hardware_document, @hardware_dc_001),
      params:
      {
        document_comment:
        {
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
        }
      }

    assert_redirected_to document_document_comment_url(@hardware_document, @hardware_dc_001)
    STDERR.puts('    The Document Comment was be updated succesfully.')
  end

  test "should destroy document_comment" do
    STDERR.puts('    Check to see that a Document Comment can be deleted.')

    assert_difference('DocumentComment.count', -1) do
      delete document_document_comment_url(@hardware_document, @hardware_dc_001)
    end

    assert_redirected_to document_document_comments_url(@hardware_document)
    STDERR.puts('    The Document Comment was be deleted succesfully.')
  end
end

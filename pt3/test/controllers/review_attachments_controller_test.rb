require 'test_helper'

class ReviewAttachmentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project           = Project.find_by(identifier: 'TEST')
    @hardware_item     = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item     = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @review            = Review.find_by(reviewid: 1)
    @review_attachment = ReviewAttachment.find_by(review_id: @review.id)
    @file_data         = Rack::Test::UploadedFile.new('test/fixtures/files/PSAC.doc',
                                                      'application/msword',
                                                      true)
    @user              = user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Review Attachment List Page can be loaded.')
    get review_review_attachments_url(@review)
    assert_response :success
    STDERR.puts('    The Review Attachment List Page loaded successfully.')
  end

  test "should show review_attachment" do
    STDERR.puts('    Check to see that the Review Attachment Show Page can be loaded.')
    get review_review_attachment_url(@review, @review_attachment)
    assert_response :success
    STDERR.puts('    The Review Attachment Show Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the Review Attachment New Page can be loaded.')
    get new_review_review_attachment_url(@review)
    assert_response :success
    STDERR.puts('    The Review Attachment New Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that the Review Attachment Edit Page can be loaded.')
    get edit_review_review_attachment_url(@review, @review_attachment)
    assert_response :success
    STDERR.puts('    The Review Attachment Edit Page loaded successfully.')
  end

  test "should create review_attachment" do
    STDERR.puts('    Check to see that a Review Attachment can be created.')
    assert_difference('ReviewAttachment.count') do
      post review_review_attachments_url(@review),
        params:
        {
          review_attachment:
          {
             review_id:        @review_attachment.review_id,
             item_id:          @review_attachment.item_id,
             project_id:       @review_attachment.project_id,
             user:             @review_attachment.user,
             organization:     @review_attachment.organization,
             link_type:        @review_attachment.link_type,
             link_description: @review_attachment.link_description,
             link_link:        @review_attachment.link_link,
             attachment_type:  @review_attachment.attachment_type,
             upload_date:      @review_attachment.upload_date,
          }
        }
    end

    assert_redirected_to review_review_attachments_url(@review)
    STDERR.puts('    The Review Attachment was created succesfully.')
  end

  test "should update review_attachment" do
    STDERR.puts('    Check to see that a Review Attachment can be updated.')
    patch review_review_attachment_url(@review, @review_attachment),
      params:
      {
        review_attachment:
        {
           review_id:        @review_attachment.review_id,
           item_id:          @review_attachment.item_id,
           project_id:       @review_attachment.project_id,
           user:             @review_attachment.user,
           organization:     @review_attachment.organization,
           link_type:        @review_attachment.link_type,
           link_description: @review_attachment.link_description,
           link_link:        @review_attachment.link_link,
           attachment_type:  @review_attachment.attachment_type,
           upload_date:      @review_attachment.upload_date,
        }
      }

    assert_redirected_to review_review_attachment_url(@review, @review_attachment)
    STDERR.puts('    The Review Attachment was updated succesfully.')
  end

  test "should destroy review_attachment" do
    STDERR.puts('    Check to see that a Review Attachment can be deleted.')
    assert_difference('ReviewAttachment.count', -1) do
      delete review_review_attachment_url(@review, @review_attachment)
    end

    assert_redirected_to review_review_attachments_url(@review)
    STDERR.puts('    The Review Attachment was deleted succesfully.')
  end
end

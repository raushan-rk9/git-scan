require 'test_helper'

class ReviewAttachmentTest < ActiveSupport::TestCase
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

  test 'review attachment record should be valid' do
    STDERR.puts('    Check to see that a Review Attachment Record with required fields filled in is valid.')
    assert_equals(true, @review_attachment.valid?,
                  'Review Attachment Record',
                  '    Expect Review Attachment Record to be valid. It was valid.')
    STDERR.puts('    The Review Attachment Record was valid.')
  end

  test 'review id shall be present for review attachment' do
    STDERR.puts('    Check to see that a Review Attachment Record without a Review ID is invalid.')

    @review_attachment.review_id = nil

    assert_equals(false, @review_attachment.valid?,
                  'Review Attachment Record',
                  '    Expect Review without review_id not to be valid. It was not valid.')
    STDERR.puts('    The Review Attachment Record was invalid.')
  end

  test 'project id shall be present for review attchment' do
    STDERR.puts('    Check to see that a Review Attachment Record without a Project ID is invalid.')

    @review_attachment.project_id = nil

    assert_equals(false, @review_attachment.valid?,
                  'Review Attachment Record',
                  '    Expect Project without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Review Attachment Record was invalid.')
  end

  test 'item id shall be present for review attchment' do
    STDERR.puts('    Check to see that a Review Attachment Record without an Item ID is invalid.')

    @review_attachment.item_id = nil

    assert_equals(false, @review_attachment.valid?,
                  'Review Attachment Record',
                  '    Expect Project without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Review Attachment Record was invalid.')
  end

  test 'user shall be present for review attachment' do
    STDERR.puts('    Check to see that a Review Attachment Record without a User ID is invalid.')
    @review_attachment.user = nil

    assert_equals(false, @review_attachment.valid?,
                  'Review Attachment Record',
                  '    Expect Review Attachment without user not to be valid. It was not valid.')
    STDERR.puts('    The Review Attachment Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.
  test 'should create review attachment' do
    STDERR.puts('    Check to see that a Review Attachment can be created.')

    review_attachment = ReviewAttachment.new({
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
                                             })

    assert_not_equals_nil(review_attachment.save, 'Review Attachment Record',
                          '    Expect Review Attachment Record to be created. It was.')
    STDERR.puts('    A Review Attachment was successfully created.')
  end

  test 'should update Review Attachment' do
    STDERR.puts('    Check to see that a Review Attachment can be updated.')

    @review_attachment.user = 'test_4@airworthinesscert.com'

    assert_not_equals_nil(@review_attachment.save, 'Review Attachment Record',
                          '    Expect Review Attachment Record to be updated. It was.')
    STDERR.puts('    A Review Attachment was successfully updated.')
  end

  test 'should delete Review Attachment' do
    STDERR.puts('    Check to see that a Review Attachment can be deleted.')
    assert( @review_attachment.destroy)
    STDERR.puts('    A Review Attachment was successfully deleted.')
  end

  test 'should create Review Attachment with undo/redo' do
    STDERR.puts('    Check to see that a Review Attachment can be created, then undone and then redone.')

    review_attachment = ReviewAttachment.new({
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
                                              })
    data_change            = DataChange.save_or_destroy_with_undo_session(review_attachment, 'create')

    assert_not_equals_nil(data_change, 'Review Attachment Record', '    Expect Review Attachment Record to be created. It was.')

    assert_difference('ReviewAttachment.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('ReviewAttachment.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Review Attachment was successfully created, then undone and then redone.')
  end

  test 'should update Review Attachment with undo/redo' do
    STDERR.puts('    Check to see that a Review Attachment can be updated, then undone and then redone.')

    @review_attachment.user = 'test_4@airworthinesscert.com'
    data_change             = DataChange.save_or_destroy_with_undo_session(@review_attachment, 'update')
    @review_attachment.user = 'test_3@airworthinesscert.com'

    assert_not_equals_nil(data_change, 'Review Attachment Record',
                          '    Expect Review Attachment Record to be updated. It was')
    assert_not_equals_nil(ReviewAttachment.find_by(user: 'test_4@airworthinesscert.com'),
                          'Review Attachment Record',
                          "    Expect Review Attachment Record's ID to be #{'test_4@airworthinesscert.com' }. It was.")
    assert_equals(nil, ReviewAttachment.find_by(user: 'test_3@airworthinesscert.com'),
                  'Review Attachment Record',
                  '    Expect original Review Attachment Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, ReviewAttachment.find_by(user: 'test_4@airworthinesscert.com'),
                  'Review Attachment Record',
                  "    Expect updated Review Attachment's Record not to found. It was not found.")
    assert_not_equals_nil(ReviewAttachment.find_by(user: 'test_3@airworthinesscert.com'),
                          'Review Attachment Record',
                          '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(ReviewAttachment.find_by(user: 'test_4@airworthinesscert.com'),
                          'Review Attachment Record',
                          "    Expect updated Review Attachment's Record to be found. It was found.")
    assert_equals(nil, ReviewAttachment.find_by(user: 'test_3@airworthinesscert.com'),
                  'Review Attachment Record',
                  '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Review Attachment was successfully updated, then undone and then redone.')
  end

  test 'should delete Review Attachment with undo/redo' do
    STDERR.puts('    Check to see that a Review Attachment can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@review_attachment, 'delete')

    assert_not_equals_nil(data_change, 'Review Attachment Record',
                          '    Expect that the delete succeded. It did.')
    assert_equals(nil,ReviewAttachment.find_by(user: 'test_3@airworthinesscert.com'),
                  'Review Attachment Record',
                  '    Verify that the Review Attachment Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(ReviewAttachment.find_by(user: 'test_3@airworthinesscert.com'),
                          'Review Attachment Record',
                          '    Verify that the Review Attachment Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, ReviewAttachment.find_by(user: 'test_3@airworthinesscert.com'),
                                                'Review Attachment Record',
                                                '    Verify that the Review Attachment Record was deleted again after redo. It was.')
    STDERR.puts('    A Review Attachment was successfully deleted, then undone and then redone.')
  end

  test 'replace_file should replace a file' do
    STDERR.puts('    Check to see that a Review Attachment can replace a file.')
    FileUtils.cp('test/fixtures/files/PSAC.doc',
                 '/var/folders/test_procedures/test/PSAC.doc')
    assert_not_equals_nil(@review_attachment.replace_file(@file_data),
                          'Data Change Record',
                          '    Expect Data Change Record to not be nil. It was.')
    STDERR.puts('    The Review Attachment successfully replaced a file.')
  end

  test 'setup_attachment should setup an attachment' do
    STDERR.puts('    Check to see that Setup Attachment can setup an attachment.')

    review_attachment            = ReviewAttachment.new
    review_attachment.review_id  = @review.id
    review_attachment.project_id = @review.project_id
    review_attachment.item_id    = @review.item_id
    review_attachment.user       = @user.email
    result                       = @review_attachment.setup_attachment(@review_attachment.link_link,
                                                                       @review_attachment.link_description,
                                                                       @review_attachment.link_type,
                                                                       Constants::REVIEW_ATTACHMENT,
                                                                       nil,
                                                                       @data_file)

    assert_equals(true, result[:status],
                  'Status from setup attachment',
                  '    Expect Status from setup attachment to be true. It was.')    
    STDERR.puts('    Setup Attachment setup an attachment successfully.')
  end
end

require "application_system_test_case"

class ReviewAttachmentsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

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

  test "visiting the index" do
    STDERR.puts('    Check to see that the Review Attachment List Page can be loaded.')
    visit review_review_attachments_url(@review)

    assert_selector "h1", text: "Review Attachments List"
    STDERR.puts('    The Review Attachment List Page was loaded successfully.')
  end


  test 'should show review attachment' do
    STDERR.puts('    Check to see that the Review attachment view Page can be loaded.')
    visit review_review_attachments_url(@review)
    assert_selector "h1", text: "Review Attachments List"
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Review: PHAC Review'
    STDERR.puts('    The Review attachment view Page was loaded.')
  end

  test "creating a Review attachment" do
    STDERR.puts('    Check to see that a Review attachment can be created.')
    visit review_review_attachments_url(@review)

    assert_selector "h1", text: "Review Attachments List"
    click_on "New Review Attachment"
    assert_selector "h1", text: "New Review Attachment"
    select('File Upload', from: 'review_attachment_link_type')
    attach_file("review_attachment_file", Rails.root + "test/fixtures/files/PSAC.doc")
    click_on "Create Review attachment"
    assert_text "Review attachment was successfully created"
    STDERR.puts('    The review attachment was created successfully.')
  end

  test "updating a Review attachment" do
    STDERR.puts('    Check to see that a Review attachment can be updated.')
    visit review_review_attachments_url(@review)
    assert_selector "h1", text: "Review Attachments List"
    click_on "Edit", match: :first
    assert_selector "h1", text: "Editing Review Attachment"
    select('File Upload', from: 'review_attachment_link_type')
    attach_file("review_attachment_file", Rails.root + "test/fixtures/files/PSAC.doc")
    click_on "Update Review attachment"
    assert_text "Review attachment was successfully updated"
    STDERR.puts('    The review attachment was updated successfully.')
  end

  test "destroying a Review attachment" do
    STDERR.puts('    Check to see that the Review attachment can be deleted.')
    visit review_review_attachments_url(@review)
    assert_selector "h1", text: "Review Attachments List"
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Review attachment was successfully removed.'
    STDERR.puts('    The review attachment was deleted successfully.')
  end
end

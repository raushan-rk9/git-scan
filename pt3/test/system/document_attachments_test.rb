require "application_system_test_case"

class DocumentAttachmentsTest < ApplicationSystemTestCase
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
    @hardware_document = Document.find_by(docid: 'PHAC',
                                          item_id: @hardware_item.id)
    @software_document = Document.find_by(docid: 'PSAC',
                                          item_id: @software_item.id)
    @hardware_da_001   = DocumentAttachment.find_by(id:      1,
                                                 item_id: @hardware_item.id)
    @software_da_001   = DocumentAttachment.find_by(id:      2,
                                                 item_id: @software_item.id)

    user_pm
  end

  test 'should get document attachments list' do
    STDERR.puts('    Check to see that the Document Attachment List Page can be loaded.')
    visit document_document_attachments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Attachments List'
    STDERR.puts('    The Document Attachments  List loaded successfully.')
  end

  test 'should show document attachment' do
    STDERR.puts('    Check to see that the document attachment Show Page can be loaded.')
    visit document_document_attachments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Attachments List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Document: PHAC.doc'
    STDERR.puts('    The document attachment Show Page was loaded.')
  end

  test 'should create new document attachment' do
    STDERR.puts('    Check to see that a Document Attachment can be created.')
    user_admin
    visit document_document_attachments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Attachments List'
    click_on 'New Document Attachment'
    attach_file("document_attachment_file", Rails.root + "test/fixtures/files/PHAC.doc")
    click_on 'Create Document attachment'
    assert_selector 'p', text: 'Document attachment was successfully created.'
    STDERR.puts('    A Document Attachment was created.')
  end

  test 'should edit new document attachment' do
    STDERR.puts('    Check to see that a Document Attachment can be updated.')
    visit document_document_attachments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Attachments List'
    assert_selector 'a', text: 'Edit'
    first('a', text: "Edit").click
    attach_file("document_attachment_file", Rails.root + "test/fixtures/files/SVCP.pdf")
    click_on 'Update Document attachment'
    STDERR.puts('    A Document Attachment was updated.')
  end

  test 'should delete document attachment' do
    STDERR.puts('    Check to see that the document attachment can be deleted.')
    visit document_document_attachments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Attachments List'
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Document attachment was successfully removed.'
    STDERR.puts('    The document attachment was deleted.')
  end
end

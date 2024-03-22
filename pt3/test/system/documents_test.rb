require "test_helper"
require "selenium/webdriver"
require "application_system_test_case"

class DocumentsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join("tmp").to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile["download.default_directory"] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  setup do
  
    @hardware_item = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user_pm
  end

  test "visiting the index" do
    STDERR.puts('    Check to see that the Document List Page can be loaded.')

    visit item_documents_url(@software_item)

    assert_selector "h1", text: "Document"
    assert_selector "a", text: "PSAC"
    assert_equal 3, Document.count

    STDERR.puts('    The Document List loaded successfully.')
  end

  test "create new document" do
    STDERR.puts('    Check to see that a new Document can be created.')

    visit item_documents_url(@software_item)

    assert_selector "h1", text: "Document"
    assert_selector "a", text: "PSAC"
    click_on('New Document')
    assert_selector "h1", text: "New Document"
    fill_in('Document ID', with: "Test Hardware Document")
    fill_in('Name', with: "Test.doc")
    select("Software Verification Plan", from: "Document type")
    select("CC1/HC1", from: "Control Category")
    attach_file("document_file", Rails.root + "test/fixtures/files/SVCP.pdf")
    click_on('Create Document')

    assert_equal 4, Document.count

    STDERR.puts('    A new document was successfully created.')
  end

  test "show document" do
    STDERR.puts('    Check to see that the Document Show Page can be loaded.')

    visit item_documents_url(@software_item)

    assert_selector "h1", text: "Document"
    assert_selector "a", text: "Show"
    click_on('Show')
    assert_selector "h5", text: "Document ID:"

    STDERR.puts('    The Document Show Page loaded successfully.')
  end

  test "edit document" do
    STDERR.puts('    Check to see that the Document Upload Page can be loaded.')

    visit item_documents_url(@software_item)

    assert_selector "h1", text: "Document"
    assert_selector "a", text: "Upload"
    click_on('Upload')
    assert_selector "h1", text: "Upload Document"

    fill_in('Document type', with: "Uploaded Test Document")
    click_on('Update Document')

    document = Document.find_by(document_type: 'Uploaded Test Document')

    assert document

    STDERR.puts('    The Document Upload Page loaded successfully.')
  end

  test "destroy document" do
    STDERR.puts('    Check to see that the Document Upload Page can be loaded.')

    visit item_documents_url(@software_item)

    assert_selector "h1", text: "Document"
    assert_selector "a", text: "Delete"
    click_on('Delete')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', "    Expect confirmation prompt to be 'Are you sure?'.")

    a.accept

    document = Document.find_by(docid: 'PSAC')

    assert_not_equals_nil(document, 'Docment Record', '    Expect Document Record to be deleted. It was.')

    STDERR.puts('    The Document Upload Page loaded successfully.')
  end

  test "download document" do
    STDERR.puts('    Check to see that the Document can be downloaded.')

    full_path = DOWNLOAD_PATH + "/PSAC.doc"

    visit item_documents_url(@software_item)

    File.delete(full_path) if File.exist?(full_path)

    assert_selector "h1", text: "Document"
    assert_selector "a", text: "Download"
    click_on('Download')

    sleep 10

    assert File.exist?(full_path)

    STDERR.puts('    The Document was successfully downloaded.')
  end

  test "should get document history" do
    STDERR.puts('    Check to see that a document history can be retrieved.')

    visit item_documents_url(@software_item)

    assert_selector "h1", text: "Document"
    assert_selector "a", text: "Show"
    click_on('Show')
    assert_selector "h5", text: "Document ID:"
    click_on('Document History')
    assert_selector "h1", text: "Document History"

    STDERR.puts('    The document history was successfully retrieved.')
  end

  test "should package documents" do
    STDERR.puts('    Check to see that documents can be packaged.')

    full_path = DOWNLOAD_PATH + "/Software Item-documents.zip"

    File.delete(full_path) if File.exist?(full_path)

    visit item_documents_url(@software_item)

    click_on('Package Certification Documents')

    assert_selector "h1", text: "Select Documents for Certification Package"

    check('select_all')
    click_on('Create Certification Package')

    sleep 10

    assert File.exist?(full_path)

    STDERR.puts('    The documents were successfully packaged.')
  end
end

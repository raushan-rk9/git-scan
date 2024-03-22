require "application_system_test_case"

class DocumentCommentsTest < ApplicationSystemTestCase
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
    @hardware_dc_001   = DocumentComment.find_by(commentid: 1,
                                                 item_id:   @hardware_item.id)
    @software_dc_001   = DocumentComment.find_by(commentid: 2,
                                                 item_id:   @software_item.id)

    user_pm
  end

  test 'should get document comments list' do
    STDERR.puts('    Check to see that the Document Comment List Page can be loaded.')
    visit document_document_comments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Comments List'
    STDERR.puts('    The Document Comments  List loaded successfully.')
  end

  test 'should show document comment' do
    STDERR.puts('    Check to see that the document comment Show Page can be loaded.')
    visit document_document_comments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Comments List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Document Comment 1'
    STDERR.puts('    The document comment Show Page was loaded.')
  end

  test 'should create new document comment' do
    STDERR.puts('    Check to see that a Document Comment can be created.')
    user_admin
    visit document_document_comments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Comments List'
    click_on 'New Document Comment'
    fill_in('document_comment_commentid', with: 2)
    page.all('div[contenteditable]')[0].send_keys('Test Document Comment to test Document Comments with.')
    click_on 'Create Document Comment'
    assert_selector 'p', text: 'Document comment was successfully created.'
    STDERR.puts('    A Document Comment was created.')
  end

  test 'should edit new document comment' do
    STDERR.puts('    Check to see that a Document Comment can be updated.')
    visit document_document_comments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Comments List'
    assert_selector 'a', text: 'Edit'
    first('a', text: "Edit").click
    page.all('div[contenteditable]')[0].send_keys(' Updated.')
    click_on 'Update Document Comment'
    assert_selector 'p', text: 'Document comment was successfully updated.'
    STDERR.puts('    A Document Comment was updated.')
  end

  test 'should delete document comment' do
    STDERR.puts('    Check to see that the document comment can be deleted.')
    visit document_document_comments_url(@hardware_document)
    assert_selector 'h1', text: 'Document Comments List'
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Document comment was successfully removed.'
    STDERR.puts('    The document comment was deleted.')
  end
end

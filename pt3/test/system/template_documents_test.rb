require "application_system_test_case"

class TemplateDocumentsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  def setup
    @template          = Template.find_by(title: 'ACS DO-254 Templates')
    @template_document = TemplateDocument.find_by(title: 'PHAC-A')

    user_pm
  end

  test "should get template documents list" do
    STDERR.puts('    Check to see that the Template Documents List Page can be loaded.')
    visit template_documents_url(awc: true)
    assert_selector "h1", text: "ACS Template Documents List"
    STDERR.puts('    The Template Documents List Page loaded successfully.')
  end

  test 'should show template document' do
    STDERR.puts('    Check to see that the Template Document Show Page can be loaded.')
    visit template_template_documents_url(@template, awc: true)
    assert_selector "h1", text: "ACS Template Documents List"
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Template Document:'
    STDERR.puts('    The Template Document Show Page was loaded.')
  end

  test "should create a Template Document" do
    STDERR.puts('    Check to see that a Template Document can be created.')
    visit template_template_documents_url(@template)
    assert_selector "h1", text: "Organization Template Documents List"
    click_on "New Template Document"
    assert_selector "h1", text: "New Template Document"
    fill_in('Title', with: 'Test Template Document to test Template Documents Items with.')
    page.all('div[contenteditable]')[0].send_keys('Test Template Document to test Template Documents Items with.')
    fill_in('Source', with: 'test')
    fill_in('template_document_document_type', with: 'PHAC Template')
    select('DO-178', from: 'template_document_document_class')
    select('A', from: 'template_document_dal')
    select('CC1/HC1', from: 'template_document_category')
    fill_in('Document ID', with: 'TESTDOC')
    fill_in('Document Name', with: 'Test Document')
    attach_file("template_document_file", Rails.root + "test/fixtures/files/SVCP.pdf")
    page.all('div[contenteditable]')[1].send_keys('Notes Test.')
    click_on "Create Template Document"
    assert_text "Template Document was successfully created."
    STDERR.puts('    A Template Document was successfully created.')
  end

  test 'should update a Template Document' do
    STDERR.puts('    Check to see that a Template Document can be updated.')
    visit template_template_documents_url(@template, awc: true)
    assert_selector "h1", text: "ACS Template Documents List"
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Template Document'
    fill_in('New Template Title', with: 'PHAC-A for Test')
    page.all('div[contenteditable]')[0].send_keys(' Updated.')
    fill_in('Source', with: 'Test')
    fill_in('template_document_document_type', with: 'PHAC Template')
    select('DO-178', from: 'template_document_document_class')
    select('A', from: 'template_document_dal')
    select('CC1/HC1', from: 'template_document_category')
    fill_in('Document ID', with: 'TESTDOC')
    fill_in('Document Name', with: 'Test Document')
    attach_file("template_document_file", Rails.root + "test/fixtures/files/PHAC.doc")
    page.all('div[contenteditable]')[1].send_keys(' Copied to Organization Template.')
    click_on "Update Template Document"
    assert_text "Template Document was successfully updated."
    STDERR.puts('    A Template Document was successfully updated.')
  end

  test "should delete a Template Document" do
    STDERR.puts('    Check to see that a Template Document can be deleted.')
    visit template_template_documents_url(@template)
    assert_selector "h1", text: "Organization Template Documents List"
    click_on "New Template Document"
    assert_selector "h1", text: "New Template Document"
    fill_in('Title', with: 'Test Template Document to test Template Documents Items with.')
    page.all('div[contenteditable]')[0].send_keys('Test Template Document to test Template Documents Items with.')
    fill_in('Source', with: 'test')
    fill_in('template_document_document_type', with: 'PHAC Template')
    select('DO-178', from: 'template_document_document_class')
    select('A', from: 'template_document_dal')
    select('CC1/HC1', from: 'template_document_category')
    fill_in('Document ID', with: 'TESTDOC')
    fill_in('Document Name', with: 'Test Document')
    attach_file("template_document_file", Rails.root + "test/fixtures/files/SVCP.pdf")
    page.all('div[contenteditable]')[1].send_keys('Notes Test.')
    click_on "Create Template Document"
    assert_text "Template Document was successfully created."
    visit template_template_documents_url(@template)
    assert_selector "h1", text: "Organization Template Documents List"
    assert_selector 'a', text: 'Delete'
    first('a', text: 'Delete').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Template Document was successfully removed.'
    STDERR.puts('    A Template Document was successfully deleted.')
  end
end

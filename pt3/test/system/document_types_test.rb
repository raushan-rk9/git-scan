require "application_system_test_case"

class DocumentTypesTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  def setup
    @hardware_dt_001 = DocumentType.find_by(document_code: 'HAS',
                                            description:   'Hardware Accomplishment Summary',
                                            dal_levels:    [ 'A' ])
    @software_dt_001 = DocumentType.find_by(document_code: 'HAS',
                                            description:   'Hardware Accomplishment Summary',
                                            dal_levels:    [ 'B' ])

    user_pm
  end

  test 'should get document types list' do
    STDERR.puts('    Check to see that the Document Type List Page can be loaded.')
    visit document_types_url(@hardware_dt_001)
    assert_selector 'h1', text: 'Document Types'
    STDERR.puts('    The Document Types  List loaded successfully.')
  end

  test 'should show document type' do
    STDERR.puts('    Check to see that the document type Show Page can be loaded.')
    visit document_types_url(@hardware_dt_001)
    assert_selector 'h1', text: 'Document Types'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    sleep 3
    assert_selector 'h5', text: 'Document Type:'
    STDERR.puts('    The document type Show Page was loaded.')
  end

  test 'should create new document type' do
    STDERR.puts('    Check to see that a Document Type can be created.')
    user_admin
    visit document_types_url(@hardware_dt_001)
    assert_selector 'h1', text: 'Document Types'
    click_on 'New Document Type'
    fill_in('document_type_document_code', with: 'XYZ')
    fill_in('document_type_description', with: 'XYZ Document')
    select('DO-178 Airborne Software', from: 'document_type_item_types')
    select('A', from: 'document_type_dal_levels')
    select('CC1/HC1', from: 'document_type_control_category')
    click_on 'Create Document Type'
    sleep 3
    assert_selector 'p', text: 'Document type was successfully created.'
    STDERR.puts('    A Document Type was created.')
  end

  test 'should edit new document type' do
    STDERR.puts('    Check to see that a Document Type can be updated.')
    visit document_types_url(@hardware_dt_001)
    assert_selector 'h1', text: 'Document Types'
    assert_selector 'a', text: 'Edit'
    first('a', text: "Edit").click
    fill_in('document_type_document_code', with: 'XYZ')
    fill_in('document_type_description', with: 'XYZ Document')
    select('DO-178 Airborne Software', from: 'document_type_item_types')
    select('A', from: 'document_type_dal_levels')
    select('CC1/HC1', from: 'document_type_control_category')
    click_on 'Update Document Type'
    sleep 3
    assert_selector 'p', text: 'Document type was successfully updated.'
    STDERR.puts('    A Document Type was updated.')
  end

  test 'should delete document type' do
    STDERR.puts('    Check to see that the document type can be deleted.')
    visit document_types_url(@hardware_dt_001)
    assert_selector 'h1', text: 'Document Types'
    assert_selector 'a', text: 'Delete'
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    sleep 3
    assert_selector 'p', text: 'Document type was successfully removed.'
    STDERR.puts('    The document type was deleted.')
  end
end

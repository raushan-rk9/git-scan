require "application_system_test_case"

class ReviewsTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join("tmp").to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile["download.default_directory"] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  Thread.current[:populate_templates] = true

  def create_review
    visit item_reviews_url(@software_item)
    assert_selector "h1", text: "Reviews List"
    click_on('New Review')
    assert_selector "h1", text: "New Review"
    fill_in('Title', with: "Test Review")
    find('div[contenteditable]').send_keys('Test Review to test Reviews with.')
    select("Peer Review", from: "Review type")
    select("Plan for Software Aspects of Certification (DO-178 Peer Review)", from: "Specific Review")
    select("PSAC.doc", from: "review_pact_file")
    click_on('Create Review')
  end

  def fillin_checklist
    create_review
    click_on('Edit Review')
    click_on('Fill in Checklist')
    select("Pass", from: "checklist_status_1")
    select("Fail", from: "checklist_status_2")
    fill_in('checklist_note_2', with: "The PSAC dose not contain a Software Overview.")
    click_on('Submit Changes')
  end

  setup do
    @hardware_item = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Review List Page can be loaded.')
    visit item_reviews_url(@software_item)
    assert_selector "h1", text: "Reviews List"
    assert_selector "td", text: "PSAC Review"
    STDERR.puts('    The Review List Page loaded successfully.')
  end

  test "should create review" do
    STDERR.puts('    Check to see that a Review can be created.')
    create_review
    assert_equal 3, Review.count
    STDERR.puts('    The Review was created successfully.')
  end

  test "should show review" do
    STDERR.puts('    Check to see that a Review can be viewed.')
    visit item_reviews_url(@software_item)
    assert_selector "h1", text: "Review"
    assert_selector "a", text: "Show"
    click_on('Show')
    assert_selector "h5", text: "Review ID:"
    STDERR.puts('    The Review was viewed successfully.')
  end

  test "should update review" do
    STDERR.puts('    Check to see that a Review can be updated.')
    visit item_reviews_url(@software_item)

    assert_selector "h1", text: "Reviews List"
    assert_selector "a", text: "Edit"
    click_on('Edit')

    assert_selector "h1", text: "Editing Review"
    fill_in('Title', with: "Test PSAC Review")
    find('div[contenteditable]').send_keys(:arrow_down)
    find('div[contenteditable]').send_keys(' - Updated.')
    click_on('Save Changes')

    review = Review.find_by(description: 'Review Plan for Software Aspects of Certification - Updated.')

    assert review

    STDERR.puts('    The Review was successfully updated.')
  end

  test "should destroy review" do
    STDERR.puts('    Check to see that a Review can be deleted.')

    visit item_reviews_url(@software_item)

    assert_selector "h1", text: "Review"
    assert_selector "a", text: "Delete"
    click_on('Delete')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', "    Expect confirmation prompt to be 'Are you sure?'.")

    a.accept

    review = Review.find_by(title: 'PSAC Review')

    assert_not_equals_nil(review, 'Review Record', '    Expect Review Record to be deleted. It was.')
    STDERR.puts('    The Review was successfully deleted.')
  end

  test "should get sign-in sheet" do
    STDERR.puts('    Check to see that a Signin Page can be loaded.')
    create_review
    click_on('Sign-In Sheet')
    click_on('Sign Review')
    click_on('Save Sign-In Sheet')
    sleep 10

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)

    sleep 10

    tag    = page.body.index('application/pdf')

#    assert tag
    STDERR.puts('    The Signin page loaded successfully.')
  end

  test "should fill-in checklist" do
    STDERR.puts('    Check to see that a Checklist can be filled in.')
    fillin_checklist
    STDERR.puts('    a Checklist was successfully filled in.')
  end

  test "get consolidated checklists" do
    STDERR.puts('    Check to see that a Consolidated Checklist Page can be loaded.')
    fillin_checklist
    click_on('Consolidated Checklist')
    STDERR.puts('    Consolidated Checklist Page was loaded successfully.')
  end

  test "export consolidated checklist" do
    full_path = DOWNLOAD_PATH + "/Test Review-Consolidated-Checklist.csv"

    File.delete(full_path) if File.exist?(full_path)

    STDERR.puts('    Check to see that a Consolidated Checklist can be exported.')
    fillin_checklist
    click_on('Consolidated Checklist')
    click_on('Export')

    window = page.driver.browser.window_handles

    File.delete(full_path) if File.exist?(full_path)

    page.driver.browser.switch_to.window(window.last)
    select("CSV", from: 'consolidated_checklist_export_export_type')
    click_on('Export')
    File.delete(full_path) if File.exist?(full_path)
    sleep 10

    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + "/Test Review-Consolidated-Checklist.docx"

    File.delete(full_path) if File.exist?(full_path)

    STDERR.puts('    Check to see that a Consolidated Checklist can be exported.')
    fillin_checklist
    click_on('Consolidated Checklist')
    sleep 5
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    select("DOCX", from: 'consolidated_checklist_export_export_type')
    click_on('Export')
    File.delete(full_path) if File.exist?(full_path)
    sleep 3
    assert File.exist?(full_path)
    STDERR.puts('    Consolidated Checklist was successfully exported.')
  end
end

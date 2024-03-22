require 'application_system_test_case'

class SourceCodesTest < ApplicationSystemTestCase
  DOWNLOAD_PATH = Rails.root.join('tmp').to_s

  Capybara.register_driver :chrome do |app|
    profile                               = Selenium::WebDriver::Chrome::Profile.new
    profile['download.default_directory'] = DOWNLOAD_PATH

    Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
  end

  Capybara.default_driver = Capybara.javascript_driver = :chrome
    driven_by :chrome, using: :chrome,  screen_size: [1400, 1400]

  setup do
    @hardware_item = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item = Item.find_by(identifier: 'SOFTWARE_ITEM')

    user = user_pm

    @github_access   = GithubAccess.new({
                                          token:                    "dfddc00137eafdc30f4580846330d5f46e2a6eec",
                                          user_id:                  user.id,
                                          last_accessed_repository: "funambol-outlook-client",
                                          last_accessed_branch:     "master",
                                          last_accessed_folder:     "outlook/UI/src",
                                          last_accessed_file:       "outlook/UI/src/AccountSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/AccountSettings.cpp\noutlook/UI/src/AccountSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/AccountSettings.h\noutlook/UI/src/AnimatedIcon.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/AnimatedIcon.cpp\noutlook/UI/src/AnimatedIcon.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/AnimatedIcon.h\noutlook/UI/src/CalendarSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/CalendarSettings.cpp\noutlook/UI/src/CalendarSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/CalendarSettings.h\noutlook/UI/src/ClientUtil.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/ClientUtil.cpp\noutlook/UI/src/ClientUtil.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/ClientUtil.h\noutlook/UI/src/ConfigFrm.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/ConfigFrm.cpp\noutlook/UI/src/ConfigFrm.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/ConfigFrm.h\noutlook/UI/src/ContactSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/ContactSettings.cpp\noutlook/UI/src/ContactSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/ContactSettings.h\noutlook/UI/src/CustomLabel.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/CustomLabel.cpp\noutlook/UI/src/CustomLabel.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/CustomLabel.h\noutlook/UI/src/CustomPane.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/CustomPane.cpp\noutlook/UI/src/CustomPane.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/CustomPane.h\noutlook/UI/src/FilesSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/FilesSettings.cpp\noutlook/UI/src/FilesSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/FilesSettings.h\noutlook/UI/src/FullSync.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/FullSync.cpp\noutlook/UI/src/FullSync.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/FullSync.h\noutlook/UI/src/LeftView.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/LeftView.cpp\noutlook/UI/src/LeftView.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/LeftView.h\noutlook/UI/src/LogSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/LogSettings.cpp\noutlook/UI/src/LogSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/LogSettings.h\noutlook/UI/src/MainSyncFrm.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/MainSyncFrm.cpp\noutlook/UI/src/MainSyncFrm.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/MainSyncFrm.h\noutlook/UI/src/MediaHubSetting.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/MediaHubSetting.cpp\noutlook/UI/src/MediaHubSetting.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/MediaHubSetting.h\noutlook/UI/src/NotesSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/NotesSettings.cpp\noutlook/UI/src/NotesSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/NotesSettings.h\noutlook/UI/src/OutlookPlugin.aps|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/OutlookPlugin.aps\noutlook/UI/src/OutlookPlugin.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/OutlookPlugin.cpp\noutlook/UI/src/OutlookPlugin.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/OutlookPlugin.h\noutlook/UI/src/OutlookPlugin.rc|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/OutlookPlugin.rc\noutlook/UI/src/OutlookPlugin.rc_IT.patch|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/OutlookPlugin.rc_IT.patch\noutlook/UI/src/OutlookPluginDoc.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/OutlookPluginDoc.cpp\noutlook/UI/src/OutlookPluginDoc.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/OutlookPluginDoc.h\noutlook/UI/src/OutlookPluginMainDoc.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/OutlookPluginMainDoc.cpp\noutlook/UI/src/OutlookPluginMainDoc.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/OutlookPluginMainDoc.h\noutlook/UI/src/PicturesSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/PicturesSettings.cpp\noutlook/UI/src/PicturesSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/PicturesSettings.h\noutlook/UI/src/Popup.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/Popup.cpp\noutlook/UI/src/ProxySettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/ProxySettings.cpp\noutlook/UI/src/ProxySettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/ProxySettings.h\noutlook/UI/src/SettingsHelper.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/SettingsHelper.cpp\noutlook/UI/src/SettingsHelper.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/SettingsHelper.h\noutlook/UI/src/Splitter.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/Splitter.cpp\noutlook/UI/src/Splitter.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/Splitter.h\noutlook/UI/src/StdAfx.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/StdAfx.cpp\noutlook/UI/src/StdAfx.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/StdAfx.h\noutlook/UI/src/SyncForm.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/SyncForm.cpp\noutlook/UI/src/SyncForm.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/SyncForm.h\noutlook/UI/src/SyncSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/SyncSettings.cpp\noutlook/UI/src/SyncSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/SyncSettings.h\noutlook/UI/src/TaskSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/TaskSettings.cpp\noutlook/UI/src/TaskSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/TaskSettings.h\noutlook/UI/src/UICustomization.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/UICustomization.cpp\noutlook/UI/src/UICustomization.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/UICustomization.h\noutlook/UI/src/Upgrading.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/Upgrading.cpp\noutlook/UI/src/Upgrading.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/Upgrading.h\noutlook/UI/src/VideosSettings.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/VideosSettings.cpp\noutlook/UI/src/VideosSettings.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/VideosSettings.h\noutlook/UI/src/Welcome.cpp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/Welcome.cpp\noutlook/UI/src/Welcome.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/Welcome.h\noutlook/UI/src/popup.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/popup.h\noutlook/UI/src/res/OutlookPlugin.exe.manifest|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/OutlookPlugin.exe.manifest\noutlook/UI/src/res/OutlookPlugin.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/OutlookPlugin.ico\noutlook/UI/src/res/OutlookPlugin.rc2|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/OutlookPlugin.rc2\noutlook/UI/src/res/Toolbar.bmp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/Toolbar.bmp\noutlook/UI/src/res/about_logo.bmp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/about_logo.bmp\noutlook/UI/src/res/about_powered_by.bmp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/about_powered_by.bmp\noutlook/UI/src/res/arrows32a.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/arrows32a.ico\noutlook/UI/src/res/arrows32b.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/arrows32b.ico\noutlook/UI/src/res/arrows32c.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/arrows32c.ico\noutlook/UI/src/res/arrows32d.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/arrows32d.ico\noutlook/UI/src/res/bg_button_blue.bmp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/bg_button_blue.bmp\noutlook/UI/src/res/bg_button_dark.bmp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/bg_button_dark.bmp\noutlook/UI/src/res/bg_button_darkblue.bmp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/bg_button_darkblue.bmp\noutlook/UI/src/res/bg_button_light.bmp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/bg_button_light.bmp\noutlook/UI/src/res/calendar.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/calendar.ico\noutlook/UI/src/res/calendar_grey.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/calendar_grey.ico\noutlook/UI/src/res/cancel.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/cancel.ico\noutlook/UI/src/res/contacts.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/contacts.ico\noutlook/UI/src/res/contacts_grey.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/contacts_grey.ico\noutlook/UI/src/res/files.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/files.ico\noutlook/UI/src/res/files_grey.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/files_grey.ico\noutlook/UI/src/res/icon_account.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/icon_account.ico\noutlook/UI/src/res/icon_account_grey.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/icon_account_grey.ico\noutlook/UI/src/res/icon_alert.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/icon_alert.ico\noutlook/UI/src/res/icon_complete.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/icon_complete.ico\noutlook/UI/src/res/icon_logo.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/icon_logo.ico\noutlook/UI/src/res/icon_sync_all.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/icon_sync_all.ico\noutlook/UI/src/res/icon_sync_all_blue.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/icon_sync_all_blue.ico\noutlook/UI/src/res/icon_syncing.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/icon_syncing.ico\noutlook/UI/src/res/icon_syncing_grey.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/icon_syncing_grey.ico\noutlook/UI/src/res/left_button.bmp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/left_button.bmp\noutlook/UI/src/res/left_separator.bmp|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/left_separator.bmp\noutlook/UI/src/res/notes.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/notes.ico\noutlook/UI/src/res/notes_grey.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/notes_grey.ico\noutlook/UI/src/res/pictures.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/pictures.ico\noutlook/UI/src/res/pictures_gr.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/pictures_gr.ico\noutlook/UI/src/res/tasks.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/tasks.ico\noutlook/UI/src/res/tasks_grey.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/tasks_grey.ico\noutlook/UI/src/res/videos.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/videos.ico\noutlook/UI/src/res/videos_grey.ico|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/res/videos_grey.ico\noutlook/UI/src/resource.h|https://github.com/PaulCarrick/funambol-outlook-client/blob/master/outlook/UI/src/resource.h",
                                        })

    @github_access.save!

    @gitlab_access   = GitlabAccess.new({
                                          username:                 "paulandvirginiacarrick@gmail.com",
                                          token:                    "uzVpuYM8xtxTs2Y1Y_vm",
                                          user_id:                  user.id,
                                          last_accessed_repository: "Demo Project",
                                          last_accessed_branch:     "master",
                                          last_accessed_folder:     "libhash",
                                          last_accessed_file:       "libhash/Android.mk|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/Android.mk\nlibhash/Makefile|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/Makefile\nlibhash/Makefile.nmake|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/Makefile.nmake\nlibhash/README.md|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/README.md\nlibhash/libhash.c|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/libhash.c\nlibhash/libhash.h|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/libhash.h\nlibhash/test_libhash.c|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/test_libhash.c\nlibhash/version.sh|https://gitlab.faaconsultants.com/patmos/demo-project/blob/master/libhash/version.sh",
                                          url:                      'https://gitlab.faaconsultants.com'
                                        })

    @gitlab_access.save!
  end

  test 'should get source codes list' do
    STDERR.puts('    Check to see that the Source Code List Page can be loaded.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'SC-001'
    assert_selector 'a', text: 'SC-002'
    visit item_source_codes_url(@hardware_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'SC-001'
    assert_selector 'a', text: 'SC-002'
    STDERR.puts('    The Source Codes  List loaded successfully.')
  end

  test 'should create new source code' do
    STDERR.puts('    Check to see that a new Source Code can be created.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'SC-001'
    click_on('New')
    assert_selector 'h1', text: 'New Source Code'
    page.all('div[contenteditable]')[0].send_keys('Test Source Code to test Source Codes with.')
    page.all('div[contenteditable]')[1].send_keys('alert_overpressure.c')
    fill_in('source_code_external_version', with: '3f983cd226ea9b5c779b0a0ad3579827')
    select('File Upload', from: 'source_code_url_type')
    attach_file("source_code_upload_file", Rails.root + "test/fixtures/files/alert_overpressure.c")
    fill_in('source_code_module', with: 'Main')
    page.all('div[contenteditable]')[2].send_keys('void main(int argc, char **argv)')
    click_on('Link High-Level Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save High-Level Requirement Links')
    click_on('Link Low-Level Requirements')
    check('select_low_level_requirement_all_low_level_requirements')
    click_on('Save Low-Level Requirement Links')
    click_on('Save Source Code')
    assert_selector 'p', text: 'Source code was successfully created.'
    visit item_source_codes_url(@hardware_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'SC-001'
    visit item_source_codes_url(@hardware_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'SC-001'
    click_on('New')
    assert_selector 'h1', text: 'New Source Code'
    page.all('div[contenteditable]')[0].send_keys('Test Source Code to test Source Codes with.')
    page.all('div[contenteditable]')[1].send_keys('alert_overpressure.c')
    fill_in('source_code_external_version', with: '3f983cd226ea9b5c779b0a0ad3579827')
    select('File Upload', from: 'source_code_url_type')
    attach_file("source_code_upload_file", Rails.root + "test/fixtures/files/alert_overpressure.c")
    fill_in('source_code_module', with: 'Main')
    page.all('div[contenteditable]')[2].send_keys('void main(int argc, char **argv)')
    click_on('Link Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save Requirement Links')
    click_on('Link Conceptual Design')
    check('select_low_level_requirement_all_low_level_requirements')
    click_on('Save Conceptual Design Links')
    click_on('Save Source Code')
    assert_selector 'p', text: 'Source code was successfully created.'
    STDERR.puts('    A new Requirement was successfully created.')
  end

  test 'should show source code' do
    STDERR.puts('    Check to see that the Source Code Show Page can be loaded.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Source Code ID:'
    visit item_source_codes_url(@hardware_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'Show'
    first('a', text: 'Show').click
    assert_selector 'h5', text: 'Source Code ID:'
    STDERR.puts('    The Source Code Show Page loaded successfully.')
  end

  test 'should edit source code' do
    STDERR.puts('    Check to see that a Source Code can be edited.')

    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'Edit'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Source Code'
    fill_in('source_code_full_id', with: 'SC-003')
    page.all('div[contenteditable]')[0].send_keys(' Updated.')
    page.all('div[contenteditable]')[1].send_keys('alert_underpressure.c')
    fill_in('source_code_external_version', with: '3f983cd226ea9b5c779b0a0ad3579827')
    select('File Upload', from: 'source_code_url_type')
    attach_file("source_code_upload_file", Rails.root + "test/fixtures/files/alert_underpressure.c")
    fill_in('source_code_module', with: 'Application')
    page.all('div[contenteditable]')[2].send_keys('void main(int argc, char argv[][])')
    click_on('Link High-Level Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save High-Level Requirement Links')
    click_on('Link Low-Level Requirements')
    check('select_low_level_requirement_all_low_level_requirements')
    click_on('Save Low-Level Requirement Links')
    click_on('Save Source Code')
    assert_selector 'p', text: 'Source Code was successfully updated.'

    source_code = SourceCode.find_by(full_id: 'SC-003',
                                     item_id: @software_item.id)

    assert source_code
    visit item_source_codes_url(@hardware_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'SC-001'
    first('a', text: 'Edit').click
    assert_selector 'h1', text: 'Editing Source Code'
    fill_in('source_code_full_id', with: 'SC-004')
    page.all('div[contenteditable]')[0].send_keys(' Updated.')
    page.all('div[contenteditable]')[1].send_keys('alert_underpressure.c')
    fill_in('source_code_external_version', with: '7d60fff00daf08e587193a8153f7fc6d')
    select('File Upload', from: 'source_code_url_type')
    attach_file("source_code_upload_file", Rails.root + "test/fixtures/files/alert_underpressure.c")
    fill_in('source_code_module', with: 'Application')
    page.all('div[contenteditable]')[2].send_keys('void main(int argc, char argv[][])')
    click_on('Link Requirements')
    check('select_high_level_requirement_all_high_level_requirements')
    click_on('Save Requirement Links')
    click_on('Link Conceptual Design')
    check('select_low_level_requirement_all_low_level_requirements')
    click_on('Save Conceptual Design Links')

    click_on('Save Source Code')
    assert_selector 'p', text: 'Source Code was successfully updated.'

    source_code = SourceCode.find_by(full_id: 'SC-004',
                                     item_id: @hardware_item.id)

    assert source_code
    STDERR.puts('    A Source Code was edited successfully.')
  end

  test 'should delete source code' do
    STDERR.puts('    Check to see that the Source Code can be deleted.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', exact_text: "delete\nDelete"
    first('a', exact_text: "delete\nDelete").click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Source code was successfully removed.'
    STDERR.puts('    The Source Code was successfully deleted.')
  end

  test 'should mark source code as deleted' do
    STDERR.puts('    Check to see that the Source Code can be marked as deleted.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    assert_selector 'a', text: 'Mark As Deleted'
    first('a', text: 'Mark As Deleted').click

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Source code was successfully marked as deleted.'
    STDERR.puts('    The Source Code was successfully deleted.')
  end

  test 'should export source codes' do
    STDERR.puts('    Check to see that the Source Codes can be exported.')

    full_path = DOWNLOAD_PATH + '/Software Item-Source_Codes.csv'

    File.delete(full_path) if File.exist?(full_path)
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Source Code'
    select('CSV', from: 'sc_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Hardware Item-Source_Codes.xls'

    File.delete(full_path) if File.exist?(full_path)
    visit item_source_codes_url(@hardware_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Source Code'
    select('XLS', from: 'sc_export_export_type')
    click_on('Export')
    sleep(3)
    assert File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-Source_Codes.pdf'

    File.delete(full_path) if File.exist?(full_path)
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Source Code'
    select('PDF', from: 'sc_export_export_type')
    click_on('Export')
    sleep(10)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)

    full_path = DOWNLOAD_PATH + '/Software Item-Source_Codes.docx'

    File.delete(full_path) if File.exist?(full_path)
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Export')

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    assert_selector 'h1', text: 'Export Source Code'
    select('DOCX', from: 'sc_export_export_type')
    click_on('Export')
    sleep(3)

    window = page.driver.browser.window_handles

    page.driver.browser.switch_to.window(window.last)
    File.delete(full_path) if File.exist?(full_path)
    STDERR.puts('    The Source Codes were successfully exported.')
  end

  test 'should import source codes' do
    STDERR.puts('    Check to see that the Source Codes can be imported.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Import')
    select('Software Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Source_Codes.csv')
    check('_import_duplicates_permitted')
    click_on('Load Source Codes')
    assert_selector 'p', text: 'Source Code requirements were successfully imported.'
    visit item_source_codes_url(@hardware_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Import')
    select('Hardware Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Source_Codes.xls')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Source Codes')
    assert_selector 'p', text: 'Source Code requirements were successfully imported.'
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Import')
    select('Software Item', from: 'llr_item_input')
    attach_file('_import_file', Rails.root + 'test/fixtures/files/Hardware Item-Source_Codes.xlsx')
    check('_import_duplicates_permitted')
    check('_import_association_changes_permitted')
    click_on('Load Source Codes')
    assert_selector 'p', text: 'Source Code requirements were successfully imported.'
    STDERR.puts('    The Source Codes were successfully imported.')
  end

  test 'should renumber source codes' do
    STDERR.puts('    Check to see that the Source Code can be renumbered.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Renumber')

    a = page.driver.browser.switch_to.alert

    assert_equals('Are you sure?', a.text, 'Confirmation Prompt', '    Expect confirmation prompt to be "Are you sure?".')
    a.accept
    assert_selector 'p', text: 'Source Codes were successfully renumbered.'
    STDERR.puts('    The Source Codes were renumbered.')
  end

  test 'should create source codes baseline' do
    STDERR.puts('    Check to see that the Source Code can be baseline.')

# There is an issue in fixtures with attached model files for now unlink them.
# THis would not occur in real life as model files are attached at creation.

    sysreqs = SystemRequirement.all

    sysreqs.each do |sysreq|
      sysreq.model_file_id = nil

      sysreq.save!
    end

    hlrs = HighLevelRequirement.all

    hlrs.each do |hlr|
      hlr.model_file_id = nil

      hlr.save!
    end

    llrs = LowLevelRequirement.all

    llrs.each do |llr|
      llr.model_file_id = nil

      llr.save!
    end

    scs = SourceCode.all

    scs.each do |sc|
      sc.file_path = nil

      sc.save!
    end

    tcs = TestCase.all

    tcs.each do |tc|
      tc.model_file_id = nil

      tc.save!
    end

    FileUtils.cp('test/fixtures/files/alert_underpressure.c',
                '/var/folders/source_codes/test/alert_underpressure.c')

   visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('New Baseline')
    click_on('Create Source Code Baseline')
    assert_selector 'p', text: 'Source Code baseline was successfully created.'
    STDERR.puts('    The Source Codes were baselined.')
  end

  test 'should view source codes baselines' do
    STDERR.puts('    Check to see that the Source Code Baselines List Page can be loaded.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('View Baselines')
    assert_selector 'h1', text: 'Source Code Baselines List'
    STDERR.puts('    The Source Code Baselines loaded successfully.')
  end

  test 'should do code coverage' do
    STDERR.puts('    Check to see that the Source Codes can be processed.')
    CodeCheckmark.destroy_all
    CodeCheckmarkHit.destroy_all
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Set Up Coverage')
    assert_selector 'h1', text: 'Set Up Source Code Coverage'
    all("input[type='checkbox']")[1].check
    find('#autoinstrument').select('Yes')
    select('CMARK', from: 'cmark')
    click_on('Done')
    assert_selector 'p', text: 'Source Codes were successfully instrumented.'

    ccms = CodeCheckmark.all.order(:checkmark_id)

    File.open('test/fixtures/files/overpressure-cmark.log', 'w') do |file|
      ccms.each { |ccm| file.puts ccm.checkmark_id }
    end

    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Process')
    assert_selector 'h1', text: 'Process Code Run Results'
    all("input[type='checkbox']")[1].check
    attach_file("source_code_upload_file", Rails.root + "test/fixtures/files/overpressure-cmark.log")
    click_on('Process Code Run Results')
    sleep(5)
    assert_selector 'p', text: 'Run results successfully processed.'
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Profile')
    assert_selector 'td', text: 'SC-001'
    assert_selector 'td', text: 'alert_overpressure.c'
    assert_selector 'td', text: '83'
    assert_selector 'td', text: '0'
    assert_selector 'td', text: '100.00%'
    STDERR.puts('    The Source Codes were processed successfully.')
  end

  test 'should scan github' do
    STDERR.puts('    Check to see that the a GitHub repository can be scanned.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    click_on('Scan GitHub')
    sleep(10)
    click_on('Scan')
    check('select_all')
    click_on('Done')
    sleep(10)
    assert_selector 'p', text: 'Source Code files were successfully generated.'
    STDERR.puts('    A GitHub repository was scanned successfully.')
  end

  test 'should scan gitlab' do
    STDERR.puts('    Check to see that the a GitLab repository can be scanned.')
    visit item_source_codes_url(@software_item)
    assert_selector 'h1', text: 'Source Code List'
    sleep(3)
    click_on('Scan GitLab')
    sleep(15)
    click_on('Scan')
    check('select_all')
    click_on('Done')
    sleep(10)
    assert_selector 'p', text: 'Source Code files were successfully generated.'
    STDERR.puts('    A GitLab repository was scanned successfully.')
  end
end

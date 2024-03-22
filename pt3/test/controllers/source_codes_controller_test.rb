require 'test_helper'

class SourceCodesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project         = Project.find_by(identifier: 'TEST')
    @hardware_item   = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item   = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_sc_001 = SourceCode.find_by(item_id: @hardware_item.id,
                                          full_id: 'SC-001')
    @hardware_sc_002 = SourceCode.find_by(item_id: @hardware_item.id,
                                          full_id: 'SC-002')
    @software_sc_001 = SourceCode.find_by(item_id: @software_item.id,
                                          full_id: 'SC-001')
    @software_sc_002 = SourceCode.find_by(item_id: @software_item.id,
                                          full_id: 'SC-002')
    @model_file      = ModelFile.find_by(full_id: 'MF-001')
    user             = user_pm
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

  test "should get index" do
    STDERR.puts('    Check to see that the Source Codes List Page can be loaded.')
    get item_source_codes_url(@hardware_item)
    assert_response :success
    STDERR.puts('    The Source Codes List Page loaded successfully.')
  end

  test "should show source code" do
    STDERR.puts('    Check to see that a Source Code can be viewed.')
    get item_source_code_url(@hardware_item, @hardware_sc_001)
    assert_response :success
    STDERR.puts('    The Source Code view loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Source Codes Page can be loaded.')
    get new_item_source_code_url(@hardware_item)
    assert_response :success
    STDERR.puts('    A new Source Codes Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit Source Code Page can be loaded.')
    get edit_item_source_code_url(@hardware_item, @hardware_sc_001)
    assert_response :success
    STDERR.puts('    The Edit Source Code page loaded successfully.')
  end

  test "should create source code" do
    STDERR.puts('    Check to see that a Source Code can be created.')

    assert_difference('SourceCode.count') do
      post item_source_codes_url(@hardware_item),
        params:
        {
          source_code:
          {
             codeid:                              @hardware_sc_001.codeid + 2,
             full_id:                             'SC-003',
             file_name:                           @hardware_sc_001.file_name,
             module:                              @hardware_sc_001.module,
             function:                            @hardware_sc_001.function,
             derived:                             @hardware_sc_001.derived,
             derived_justification:               @hardware_sc_001.derived_justification,
             low_level_requirement_associations:  @hardware_sc_001.low_level_requirement_associations,
             url_type:                            @hardware_sc_001.url_type,
             url_description:                     @hardware_sc_001.url_description,
             url_link:                            @hardware_sc_001.url_link,
             version:                             @hardware_sc_001.version,
             organization:                        @hardware_sc_001.organization,
             item_id:                             @hardware_sc_001.item_id,
             project_id:                          @hardware_sc_001.project_id,
             archive_id:                          @hardware_sc_001.archive_id,
             high_level_requirement_associations: @hardware_sc_001.high_level_requirement_associations,
             description:                         @hardware_sc_001.description,
             soft_delete:                         @hardware_sc_001.soft_delete,
             file_path:                           @hardware_sc_001.file_path,
             content_type:                        @hardware_sc_001.content_type,
             file_type:                           @hardware_sc_001.file_type,
             revision:                            @hardware_sc_001.revision,
             draft_version:                       @hardware_sc_001.draft_version,
             revision_date:                       @hardware_sc_001.revision_date,
             upload_date:                         @hardware_sc_001.upload_date,
             external_version:                    @hardware_sc_001.external_version
          }
        }
    end

    assert_redirected_to item_source_code_url(@hardware_item, SourceCode.last)
    STDERR.puts('    The Source Code was created successfully.')
  end

  test "should update source code" do
    STDERR.puts('    Check to see that a Source Code can be updated.')

    patch item_source_code_url(@hardware_item, @hardware_sc_001),
      params:
      {
        source_code:
        {
             codeid:                              @hardware_sc_001.codeid + 2,
             full_id:                             'SC-003',
             file_name:                           @hardware_sc_001.file_name,
             module:                              @hardware_sc_001.module,
             function:                            @hardware_sc_001.function,
             derived:                             @hardware_sc_001.derived,
             derived_justification:               @hardware_sc_001.derived_justification,
             low_level_requirement_associations:  @hardware_sc_001.low_level_requirement_associations,
             url_type:                            @hardware_sc_001.url_type,
             url_description:                     @hardware_sc_001.url_description,
             url_link:                            @hardware_sc_001.url_link,
             version:                             @hardware_sc_001.version,
             organization:                        @hardware_sc_001.organization,
             item_id:                             @hardware_sc_001.item_id,
             project_id:                          @hardware_sc_001.project_id,
             archive_id:                          @hardware_sc_001.archive_id,
             high_level_requirement_associations: @hardware_sc_001.high_level_requirement_associations,
             description:                         @hardware_sc_001.description,
             soft_delete:                         @hardware_sc_001.soft_delete,
             file_path:                           @hardware_sc_001.file_path,
             content_type:                        @hardware_sc_001.content_type,
             file_type:                           @hardware_sc_001.file_type,
             revision:                            @hardware_sc_001.revision,
             draft_version:                       @hardware_sc_001.draft_version,
             revision_date:                       @hardware_sc_001.revision_date,
             upload_date:                         @hardware_sc_001.upload_date,
             external_version:                    @hardware_sc_001.external_version
        }
      }

    assert_redirected_to item_source_code_url(@hardware_item, @hardware_sc_001, previous_mode: 'editing')
    STDERR.puts('    The Source Code was successfully updated.')
  end

  test "should destroy source code" do
    STDERR.puts('    Check to see that a Source Code can be deleted.')

    assert_difference('SourceCode.count', -1) do
      delete item_source_code_url(@hardware_item, @hardware_sc_001)
    end

    assert_redirected_to item_source_codes_url(@hardware_item)
    STDERR.puts('    The Source Code was successfully deleted.')
  end

  test "should export source codes" do
    STDERR.puts('    Check to see that a Source Code can be exported.')
    get item_source_codes_export_url(@hardware_item)
    assert_response :success

    post item_source_codes_export_url(@hardware_item),
      params:
      {
        sc_export:
        {
          export_type: 'CSV'
        }
      }

    assert_redirected_to item_source_codes_export_url(@hardware_item, :format => :csv)
    get item_source_codes_export_url(@hardware_item, :format => :csv)
    assert_response :success

    lines = response.body.split("\n")

    assert_equals('id,codeid,full_id,file_name,module,function,derived,derived_justification,version,item_id,project_id,url_type,url_link,url_description,created_at,updated_at,organization,low_level_requirement_associations,high_level_requirement_associations,soft_delete,file_path,content_type,file_type,revision,draft_version,revision_date,upload_date,external_version,archive_revision,archive_version',
                  lines[0], 'Header',
                  '    Expect header to be id,codeid,full_id,file_name,module,function,derived,derived_justification,version,item_id,project_id,url_type,url_link,url_description,created_at,updated_at,organization,low_level_requirement_associations,high_level_requirement_associations,soft_delete,file_path,content_type,file_type,revision,draft_version,revision_date,upload_date,external_version,archive_revision,archive_version. It was.')

    get item_source_codes_export_url(@hardware_item)
    assert_response :success

    post item_source_codes_export_url(@hardware_item),
      params:
      {
        sc_export:
        {
          export_type: 'PDF'
        }
      }

    assert_redirected_to item_source_codes_export_url(@hardware_item, :format => :pdf)
    get item_source_codes_export_url(@hardware_item, :format => :pdf)
    assert_response :success
    assert_between(18000, 24000, response.body.length, 'PDF Download Length', "    Expect PDF download length to be btween 18000 and 24000.")
    get item_source_codes_export_url(@hardware_item)
    assert_response :success

    post item_source_codes_export_url(@hardware_item),
      params:
      {
        sc_export:
        {
          export_type: 'XLS'
        }
      }

    assert_redirected_to item_source_codes_export_url(@hardware_item, :format => :xls)
    get item_source_codes_export_url(@hardware_item, :format => :xls)
    assert_response :success
    assert_equals(true, ((response.body.length > 9000) && (response.body.length < 10000)), 'XLS Download Length', "    Expect XLS download length to be > 5000. It was...")
    get item_source_codes_export_url(@hardware_item)
    assert_response :success

    post item_source_codes_export_url(@hardware_item),
      params:
      {
        sc_export:
        {
          export_type: 'HTML'
        }
      }

    assert_response :success
    STDERR.puts('    A Source Code was exported.')
  end

  test "should import source codes" do
    STDERR.puts('    Check to see that a Source Code file can be imported.')
    get item_source_codes_import_url(@hardware_item)
    assert_response :success

    post item_source_codes_import_url(@hardware_item),
      params:
      {
        '/import' =>
        {
          item_select:                   @hardware_item.id,
          duplicates_permitted:          '1',
          association_changes_permitted: '1',
          file:                          fixture_file_upload('files/Hardware Item-Source_Codes.csv')
        }
      }

    assert_redirected_to item_source_codes_url(@hardware_item)
    STDERR.puts('    A Source Code file was imported.')
  end

  test "should renumber" do
    STDERR.puts('    Check to see that the Source Codes can be renumbered.')
    get item_source_codes_renumber_url(@hardware_item)
    assert_redirected_to item_source_codes_url(@hardware_item)
    STDERR.puts('    The Source Codes were successful renumbered.')
  end

  test "should mark as deleted" do
    STDERR.puts('    Check to see that the Source Codes can be marked as deleted.')
    get item_source_code_mark_as_deleted_url(@hardware_item, @hardware_sc_001)
    assert_redirected_to item_source_codes_url(@hardware_item)
    STDERR.puts('    The Source Codes was successfully marked as deleted.')
  end

  test "should scan github" do
    STDERR.puts('    Check to see that Github can be scanned for the Source Codes.')
    get item_source_codes_scan_github_url(@hardware_item)
    assert_response :success
    STDERR.puts('    Github was successfully scanned.')
  end

  test "should select github files" do
    STDERR.puts('    Check to see that Github Github Files can be selected.')
    get item_source_codes_select_github_files_url(@hardware_item)
    assert_response :success
    STDERR.puts('    Github Files were successfully selected.')
  end

  test "should scan gitlab" do
    STDERR.puts('    Check to see that Gitlab can be scanned for the Source Codes.')
    get item_source_codes_scan_gitlab_url(@hardware_item)
    assert_response :success
    STDERR.puts('    Gitlab was successfully scanned.')
  end

  test "should select gitlab files" do
    STDERR.puts('    Check to see that Gitlab Gitlab Files can be selected.')
    get item_source_codes_select_gitlab_files_url(@hardware_item)
    assert_response :success
    STDERR.puts('    Gitlab Files were successfully selected.')
  end

  test "should instrument profile and process" do
    STDERR.puts('    Check to see that the Source Codes can be instrumented, profiled and processed.')

    put item_source_codes_instrument_url(@hardware_item),
      params:
      {
        autoinstrument:      'yes',
        cmark:               'CMARK',
        select_source_codes: "[ #{@hardware_sc_001.id}, #{@hardware_sc_002.id}  ]"
      }

    assert_redirected_to item_source_codes_path(@hardware_item)

    get item_source_codes_profile_url(@hardware_item)
    assert_response :success

    checkmarks = CodeCheckmark.where(source_code_id: @hardware_sc_001.id).order(:checkmark_id)

    File.open('test/fixtures/files/overpressure-cmark.log', 'w') do |file|
      checkmarks.each { |checkmark| file.puts checkmark.checkmark_id }
    end

    @file_data = Rack::Test::UploadedFile.new('test/fixtures/files/overpressure-cmark.log',
                                              'text/plain',
                                               true)

    put item_source_codes_process_results_url(@hardware_item),
      params:
      {
        source_code:
        {
          selected:    @hardware_sc_001.id.to_s,
          upload_file: @file_data
        }
      }

    assert_redirected_to item_source_codes_profile_path(@hardware_item)

    STDERR.puts('    The Source Codes were successful instrumented, profiled and processed.')
  end

  test "should download file" do
    STDERR.puts('    Check to see that a File can be downloded.')

    get item_source_code_download_url(@hardware_item, @hardware_sc_001)
    assert_equals(6274, response.body.length, 'Download Length', "    Expect download length to be 6274")

    STDERR.puts('    The File was successfully downloaded.')
  end

  test "should display file" do
    STDERR.puts('    Check to see that a File can be downloded.')

    get item_source_code_display_url(@hardware_item, @hardware_sc_001)
    assert_response :success

    STDERR.puts('    The File was successfully downloaded.')
  end
end

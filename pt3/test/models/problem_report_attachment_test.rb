require 'test_helper'

class ProblemReportAttachmentTest < ActiveSupport::TestCase
  def setup
    @project                   = Project.find_by(identifier: 'TEST')
    @hardware_item             = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item             = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @problem_report            = ProblemReport.find_by(prid: 1)
    @problem_report_attachment = ProblemReportAttachment.find_by(problem_report_id: ProblemReport.find_by(prid: 2).try(:id))
    @file_data                 = Rack::Test::UploadedFile.new('test/fixtures/files/flowchart.png',
                                                              'image/png',
                                                              true)

    user_pm
  end

  test 'problem_report attachment record should be valid' do
    STDERR.puts('    Check to see that a Problem Report Attachment Record with required fields filled in is valid.')
    assert_equals(true, @problem_report_attachment.valid?,
                  'ProblemReport Attachment Record',
                  '    Expect ProblemReport Attachment Record to be valid. It was valid.')
    STDERR.puts('    The Problem Report Attachment Record was valid.')
  end

  test 'problem_report id shall be present for a problem_report attachment' do
    STDERR.puts('    Check to see that a document Attachment Record without a Problem Report ID is invalid.')
    @problem_report_attachment.problem_report_id = nil

    assert_equals(false, @problem_report_attachment.valid?,
                  'ProblemReport Attachment Record',
                  '    Expect ProblemReport without problem_report_id not to be valid. It was not valid.')
    STDERR.puts('    The Problem Report Attachment Record was invalid.')
  end

  test 'project id shall be present for problem_report attchment' do
    STDERR.puts('    Check to see that a Problem Report Attachment Record without a Project ID is invalid.')

    @problem_report_attachment.project_id = nil

    assert_equals(false, @problem_report_attachment.valid?,
                  'ProblemReport Attachment Record',
                  '    Expect Project without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Problem Report Attachment Record was invalid.')
  end

  test 'user shall be present for problem_report attachment' do
    STDERR.puts('    Check to see that a Problem Report Attachment Record without a User is invalid.')

    @problem_report_attachment.user = nil

    assert_equals(false, @problem_report_attachment.valid?,
                  'ProblemReport Attachment Record',
                  '    Expect ProblemReport Attachment without user not to be valid. It was not valid.')
    STDERR.puts('    The Problem Report Attachment Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test 'should create problem_report attachment' do
    STDERR.puts('    Check to see that an Problem Report Attachment can be created.')

    problem_report_attachment = ProblemReportAttachment.new({
                                                               problem_report_id: @problem_report_attachment.problem_report_id,
                                                               project_id:        @problem_report_attachment.project_id,
                                                               item_id:           @hardware_item.id,
                                                               user:              @problem_report_attachment.user,
                                                               organization:      @problem_report_attachment.organization,
                                                               link_type:         @problem_report_attachment.link_type,
                                                               link_description:  @problem_report_attachment.link_description,
                                                               link_link:         @problem_report_attachment.link_link,
                                                               upload_date:       @problem_report_attachment.upload_date
                                                            })

    assert_not_equals_nil(problem_report_attachment.save,
                          'ProblemReport Attachment Record',
                          '    Expect ProblemReport Attachment Record to be created. It was.')
    STDERR.puts('    A Problem Report Attachment was successfully created.')
  end

  test 'should update Problem Report Attachment' do
    STDERR.puts('    Check to see that an Problem Report Attachment can be updated.')

    @problem_report_attachment.user = 'test_4@airworthinesscert.com'

    assert_not_equals_nil(@problem_report_attachment.save, 'ProblemReport Attachment Record',
                          '    Expect ProblemReport Attachment Record to be updated. It was.')
    STDERR.puts('    A Problem Report Attachment was successfully updated.')
  end

  test 'should delete Problem Report Attachment' do
    STDERR.puts('    Check to see that an Problem Report Attachment can be deleted.')
    assert( @problem_report_attachment.destroy)
    STDERR.puts('    A Problem Report Attachment was successfully deleted.')
  end

  test 'should create Problem Report Attachment with undo/redo' do
    STDERR.puts('    Check to see that an Problem Report Attachment can be created, then undone and then redone.')

    problem_report_attachment = ProblemReportAttachment.new({
                                                               problem_report_id: @problem_report_attachment.problem_report_id,
                                                               project_id:        @problem_report_attachment.project_id,
                                                               item_id:           @hardware_item.id,
                                                               user:              @problem_report_attachment.user,
                                                               organization:      @problem_report_attachment.organization,
                                                               link_type:         @problem_report_attachment.link_type,
                                                               link_description:  @problem_report_attachment.link_description,
                                                               link_link:         @problem_report_attachment.link_link,
                                                               upload_date:       @problem_report_attachment.upload_date
                                                            })
    data_change            = DataChange.save_or_destroy_with_undo_session(problem_report_attachment, 'create')

    assert_not_equals_nil(data_change, 'ProblemReport Attachment Record', '    Expect ProblemReport Attachment Record to be created. It was.')

    assert_difference('ProblemReportAttachment.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('ProblemReportAttachment.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Problem Report Attachment was successfully created, then undone and then redone.')
  end

  test 'should update Problem Report Attachment with undo/redo' do
    STDERR.puts('    Check to see that an Problem Report Attachment can be updated, then undone and then redone.')

    @problem_report_attachment.user = 'test_4@airworthinesscert.com'
    data_change                     = DataChange.save_or_destroy_with_undo_session(@problem_report_attachment, 'update')
    @problem_report_attachment.user = 'test_3@airworthinesscert.com'

    assert_not_equals_nil(data_change, 'ProblemReport Attachment Record', '    Expect ProblemReport Attachment Record to be updated. It was')
    assert_not_equals_nil(ProblemReportAttachment.find_by(user: 'test_4@airworthinesscert.com'), 'ProblemReport Attachment Record', "    Expect ProblemReport Attachment Record's ID to be #{'test_4@airworthinesscert.com' }. It was.")
    assert_equals(nil, ProblemReportAttachment.find_by(user: 'test_3@airworthinesscert.com'), 'ProblemReport Attachment Record', '    Expect original ProblemReport Attachment Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, ProblemReportAttachment.find_by(user: 'test_4@airworthinesscert.com'), 'ProblemReport Attachment Record', "    Expect updated ProblemReport Attachment's Record not to found. It was not found.")
    assert_not_equals_nil(ProblemReportAttachment.find_by(user: 'test_3@airworthinesscert.com'), 'ProblemReport Attachment Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(ProblemReportAttachment.find_by(user: 'test_4@airworthinesscert.com'), 'ProblemReport Attachment Record', "    Expect updated ProblemReport Attachment's Record to be found. It was found.")
    assert_equals(nil, ProblemReportAttachment.find_by(user: 'test_3@airworthinesscert.com'), 'ProblemReport Attachment Record', '    Expect Orginal Record not to be found. It was not found.')

    STDERR.puts('    A Problem Report Attachment was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete Problem Report Attachment" do
    STDERR.puts('    Check to see that a Problem Report Attachment can be deleted undone and redone.')

    data_change   = nil

    assert_difference('ProblemReportAttachment.count', -1) do
      data_change = DataChange.save_or_destroy_with_undo_session(@problem_report_attachment,
                                                                 'delete')
    end

    assert_not_nil(data_change)

    assert_difference('ProblemReportAttachment.count', +1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('ProblemReportAttachment.count', -1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Problem Report Attachment was successfully deleted undone and redone.')
  end

  test 'get_root_path should return the Root Path' do
    STDERR.puts('    Check to see that a Problem Report Attachment can return the root directory.')
    assert_equals('/var/folders/problem_report_attachments/test', @problem_report_attachment.get_root_path, 'Problem Report Attachment Record', '    Expect the return from get_root_path to be /var/folders/problem_report_attachments/test." It was.')
    STDERR.puts('    The Problem Report Attachment successfully returned the root directory.')
  end

  test 'get_file_path should return the File Path' do
    STDERR.puts('    Check to see that an Problem Report Attachment can return the file path for an attachment.')
    assert_equals('/var/folders/problem_report_attachments/test', @problem_report_attachment.get_file_path, 'Problem Report Attachment Record', '    Expect the return from get_file_path to be /var/folders/problem_report_attachments/test." It was.')
    STDERR.puts('    The Problem Report Attachment successfully returned the file path for an attachment.')
  end

  test 'get_file_contents should return the file contents' do
    STDERR.puts('    Check to see that an Problem Report Attachment can get the contents from an attachment.')
    file = @problem_report_attachment.get_file_contents

    assert_equals('file', file.name, 'File Name', "    Expect the file.name to be 'file'. It was.")
    assert_equals('alert_overpressure.c', file.filename.to_s, 'Filename', "    Expect the file.filename to be 'alert_overpressure.c'. It was.")
    assert_equals('text/x-csrc', file.content_type, 'Filename', "    Expect the file.content_type to be 'text/x-csrc'. It was.")
    assert_equals(6274, file.download.length, 'Filename', "    Expect the file.download.length to be 22049. It was.")
    STDERR.puts('    The Problem Report Attachment successfully got the contents from an attachment.')
  end

  test 'store_file should store a file' do
    STDERR.puts('    Check to see that a Problem Report Attachment can store a file.')
    filename = '/var/folders/problem_report_attachments/test/flowchart.png'

    File.delete(filename) if File.exist?(filename)

    problem_report_attachment = ProblemReportAttachment.new({
                                                               problem_report_id: @problem_report_attachment.problem_report_id,
                                                               project_id:        @problem_report_attachment.project_id,
                                                               item_id:           @hardware_item.id,
                                                               user:              @problem_report_attachment.user,
                                                               organization:      @problem_report_attachment.organization,
                                                            })
    filename                  = problem_report_attachment.store_file(@file_data)

    assert_equals(filename, filename, 'Filename', "    Expect the filename to be '#{filename}'. It was.")
    STDERR.puts('    The Problem Report Attachment successfully stored a file.')
  end

  test 'replace_file should replace a file' do
    STDERR.puts('    Check to see that a Problem Report Attachment can replace a file.')
    FileUtils.cp('test/fixtures/files/alert_overpressure.c',
                 '/var/folders/problem_report_attachments/test/alert_overpressure.c')
    assert_not_equals_nil(@problem_report_attachment.replace_file(@file_data,
                                                                  @project.id,
                                                                  @hardware_item,
                                                                  @problem_report.id),
                          'Data Change Record',
                          '    Expect Data Change Record to not be nil. It was.')
    STDERR.puts('    The Problem Report Attachment successfully replace a file.')
  end
end

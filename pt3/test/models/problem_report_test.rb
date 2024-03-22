require 'test_helper'

class ProblemReportTest < ActiveSupport::TestCase
  def compare_prs(x, y,
                   attributes = [
                                   'project_id',
                                   'item_id',
                                   'prid',
                                   'status',
                                   'openedby',
                                   'title',
                                   'product',
                                   'criticality',
                                   'source',
                                   'discipline_assigned',
                                   'assignedto',
                                   'description',
                                   'problemfoundin',
                                   'correctiveaction',
                                   'fixed_in',
                                   'verification',
                                   'feedback',
                                   'notes',
                                   'meeting_id',
                                   'safetyrelated',
                                   'referenced_artifacts'
                               ])

    result = false

    return result unless x.present? && y.present?

    attributes.each do |attribute|
      if x.attributes[attribute].present? && y.attributes[attribute].present?
        result = (x.attributes[attribute] == y.attributes[attribute])
      elsif !x.attributes[attribute].present? && !y.attributes[attribute].present?
        result = true
      else
        result = false
      end

      unless result
        puts "#{attribute}: #{x.attributes[attribute]}, #{y.attributes[attribute]}"

        break
      end
    end

    return result
  end

  setup do
    @project        = Project.find_by(identifier: 'TEST')
    @problem_report = ProblemReport.find_by(prid: 1)

    user_pm
  end

  test "problem report record should be valid" do
    STDERR.puts('    Check to see that a Problem Report Record with required fields filled in is valid.')
    assert_equals(true, @problem_report.valid?, 'Problem Report Record', '    Expect Problem Report Record to be valid. It was valid.')
    STDERR.puts('    The Problem Report Record was valid.')
  end

  test "prid should be present" do
    STDERR.puts('    Check to see that a Problem Report Record without a Problem Report ID is invalid.')

    @problem_report.prid = nil

    assert_equals(false, @problem_report.valid?, 'Problem Report Record', '    Expect Problem Report without prid not to be valid. It was not valid.')
    STDERR.puts('    The Problem Report Record was invalid.')
  end

  test "project_id should be present" do
    STDERR.puts('    Check to see that a Problem Report Record without a Project ID is invalid.')

    @problem_report.project_id = nil

    assert_equals(false, @problem_report.valid?, 'Problem Report Record', '    Expect Problem Report without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Problem Report Record was invalid.')
  end

  test "title should be present" do
    STDERR.puts('    Check to see that a Problem Report Record without a Title is invalid.')

    @problem_report.title = nil

    assert_equals(false, @problem_report.valid?, 'Problem Report Record', '    Expect Problem Report without title not to be valid. It was not valid.')
    STDERR.puts('    The Problem Report Record was invalid.')
  end

  test "fullprid should be correct" do
    STDERR.puts('    Check to see that the Problem Report returns a proper Full ID.')

    @problem_report.fullprid

    assert_equals('TEST-PR-1', @problem_report.fullprid, 'Problem Report Record', '    Expect fullprid to be "TEST-PR-1". It was.')
    STDERR.puts('    The Problem Report returned a proper Full ID successfully.')
  end

  test "fullprwithdesc should be correct" do
    STDERR.puts('    Check to see that the Problem Report returns a proper Full ID with Description.')

    @problem_report.fullprwithdesc

    assert_equals('TEST-PR-1: When operating in environments in excess of 100c communications fails.<br>Add cooling fan or heat sink.', @problem_report.fullprwithdesc, 'Problem Report Record', '    Expect fullprwithdesc to be "TEST-PR-1: When operating in environments in excess of 100c communications fails.<br>Add cooling fan or heat sink.". It was.')
    STDERR.puts('    The Problem Report returned a proper Full ID with Description successfully.')
  end

  test "fullpr_with_title should be correct" do
    STDERR.puts('    Check to see that the Problem Report returns a proper Full ID with Title.')

    @problem_report.fullpr_with_title

    assert_equals('TEST-PR-1: When operating in environments in excess of 100c communications fails.', @problem_report.fullpr_with_title, 'Problem Report Record', '    Expect fullpr_with_title to be "TEST-PR-1: When operating in environments in excess of 100c communications fails.". It was.')
    STDERR.puts('    The Problem Report returned a proper Full ID with Title successfully.')
  end

  test "get_full_title should be correct" do
    STDERR.puts('    Check to see that the Problem Report returns a proper Full Title.')

    ProblemReport.get_full_title(@problem_report.id)

    assert_equals('TEST-PR-1: When operating in environments in excess of 100c communications fails.', ProblemReport.get_full_title(@problem_report.id), 'Problem Report Record', '    Expect get_full_title to be "TEST-PR-1: When operating in environments in excess of 100c communications fails.". It was.')
    STDERR.puts('    The Problem Report returned a proper Full Title successfully.')
  end

  test "Create Problem Report" do
    STDERR.puts('    Check to see that an Problem Report can be created.')

    problem_report = ProblemReport.new({
                                          project_id:           @problem_report.project_id,
                                          item_id:              @problem_report.item_id,
                                          prid:                 @problem_report.prid + 3,
                                          dateopened:           @problem_report.dateopened,
                                          status:               @problem_report.status,
                                          openedby:             @problem_report.openedby,
                                          title:                @problem_report.title,
                                          product:              @problem_report.product,
                                          criticality:          @problem_report.criticality,
                                          source:               @problem_report.source,
                                          discipline_assigned:  @problem_report.discipline_assigned,
                                          assignedto:           @problem_report.assignedto,
                                          target_date:          @problem_report.target_date,
                                          close_date:           @problem_report.close_date,
                                          description:          @problem_report.description,
                                          problemfoundin:       @problem_report.problemfoundin,
                                          correctiveaction:     @problem_report.correctiveaction,
                                          fixed_in:             @problem_report.fixed_in,
                                          verification:         @problem_report.verification,
                                          feedback:             @problem_report.feedback,
                                          notes:                @problem_report.notes,
                                          meeting_id:           @problem_report.meeting_id,
                                          safetyrelated:        @problem_report.safetyrelated,
                                          datemodified:         @problem_report.datemodified,
                                          referenced_artifacts: @problem_report.referenced_artifacts
                                       })

    assert(problem_report.save)
    STDERR.puts('    A Problem Report  was successfully created.')
  end

  test "Update Problem Report" do
    STDERR.puts('    Check to see that an Problem Report can be updated.')

    prid                  = @problem_report.prid
    @problem_report.prid += 1

    assert(@problem_report.save)

    @problem_report.prid  = prid
    STDERR.puts('    A Problem Report was successfully updated.')
  end

  test "Delete Problem Report" do
    STDERR.puts('    Check to see that an Problem Report can be deleted.')
    assert(@problem_report.destroy)
    STDERR.puts('    A Problem Report was successfully deleted.')
  end

  test "Undo/Redo Create Problem Report" do
    STDERR.puts('    Check to see that an Problem Report can be created, then undone and then redone.')

    problem_report = ProblemReport.new({
                                          project_id:           @problem_report.project_id,
                                          item_id:              @problem_report.item_id,
                                          prid:                 @problem_report.prid + 3,
                                          dateopened:           @problem_report.dateopened,
                                          status:               @problem_report.status,
                                          openedby:             @problem_report.openedby,
                                          title:                @problem_report.title,
                                          product:              @problem_report.product,
                                          criticality:          @problem_report.criticality,
                                          source:               @problem_report.source,
                                          discipline_assigned:  @problem_report.discipline_assigned,
                                          assignedto:           @problem_report.assignedto,
                                          target_date:          @problem_report.target_date,
                                          close_date:           @problem_report.close_date,
                                          description:          @problem_report.description,
                                          problemfoundin:       @problem_report.problemfoundin,
                                          correctiveaction:     @problem_report.correctiveaction,
                                          fixed_in:             @problem_report.fixed_in,
                                          verification:         @problem_report.verification,
                                          feedback:             @problem_report.feedback,
                                          notes:                @problem_report.notes,
                                          meeting_id:           @problem_report.meeting_id,
                                          safetyrelated:        @problem_report.safetyrelated,
                                          datemodified:         @problem_report.datemodified,
                                          referenced_artifacts: @problem_report.referenced_artifacts

                                      })
    data_change    = DataChange.save_or_destroy_with_undo_session(problem_report, 'create')

    assert_not_nil(data_change)

    assert_difference('ProblemReport.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('ProblemReport.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Problem Report was successfully created, then undone and then redone.')
  end

  test "Undo/Redo Update Problem Report" do
    STDERR.puts('    Check to see that an Problem Report can be updated, then undone and then redone.')

    prid                  = @problem_report.prid    
    @problem_report.prid += 3
    data_change           = DataChange.save_or_destroy_with_undo_session(@problem_report, 'update')
    @problem_report.prid  = prid

    assert_not_nil(data_change)
    assert_not_nil(ProblemReport.find_by(prid: @problem_report.prid + 3))
    assert_nil(ProblemReport.find_by(prid: @problem_report.prid))

    ChangeSession.undo(data_change.session_id)
    assert_nil(ProblemReport.find_by(prid: @problem_report.prid + 3))
    assert_not_nil(ProblemReport.find_by(prid: @problem_report.prid))

    ChangeSession.redo(data_change.session_id)
    assert_not_nil(ProblemReport.find_by(prid: @problem_report.prid + 3))
    assert_nil(ProblemReport.find_by(prid: @problem_report.prid))
    STDERR.puts('    A Problem Report was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete ProblemReport" do
    STDERR.puts('    Check to see that an Problem Report can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@problem_report, 'delete')

    assert_not_nil(data_change)
    assert_nil(ProblemReport.find_by(prid: @problem_report.prid))

    ChangeSession.undo(data_change.session_id)
    assert_not_nil(ProblemReport.find_by(prid: @problem_report.prid))

    ChangeSession.redo(data_change.session_id)
    assert_nil(ProblemReport.find_by(prid: @problem_report.prid))
    STDERR.puts('    A Problem Report was successfully deleted, then undone and then redone.')
  end

  test 'should generate CSV' do
    STDERR.puts('    Check to see that the Problem Report can generate CSV properly.')

    csv   = ProblemReport.to_csv(@project.id)
    lines = csv.split("\n")

    assert_equals('item_id,prid,dateopened,status,openedby,title,product,criticality,source,discipline_assigned,assignedto,target_date,close_date,description,problemfoundin,correctiveaction,fixed_in,verification,feedback,notes,meeting_id,safetyrelated,datemodified,archive_id,referenced_artifacts',
                  lines[0], 'Header',
                  '    Expect header to be item_id,prid,dateopened,status,openedby,title,product,criticality,source,discipline_assigned,assignedto,target_date,close_date,description,problemfoundin,correctiveaction,fixed_in,verification,feedback,notes,meeting_id,safetyrelated,datemodified,archive_id,referenced_artifacts. It was.')

    lines[1..-1].each do |line|
      assert_not_equals_nil((line =~ /^\d+,\d,20\d{2}\-\d{2}\-\d{2} \d{2}:\d{2}[AP]M UTC,(Open|Closed),.+\@.+,["A-Za-z .]+,Type.+,["A-Za-z .]+,["A-Za-z .]+,.+\@.+,20\d{2}\-\d{2}\-\d{2} \d{2}:\d{2}[AP]M UTC,.+,.+,["A-Za-z .]+,["A-Za-z .]+,["A-Za-z .]+,.*$/),
                            '    Expect line to be /^\d+,\d,20\d{2}\-\d{2}\-\d{2} \d{2}:\d{2}[AP]M UTC,(Open|Closed),.+\@.+,["A-Za-z .]+,Type.+,["A-Za-z .]+,["A-Za-z .]+,.+\@.+,20\d{2}\-\d{2}\-\d{2} \d{2}:\d{2}[AP]M UTC,.+,.+,["A-Za-z .]+,["A-Za-z .]+,["A-Za-z .]+,.*$/. It was.')
    end

    STDERR.puts('    The Problem Report generated CSV successfully.')
  end

  test 'should generate XLS' do
    STDERR.puts('    Check to see that the Problem Report can generate XLS properly.')

    assert_nothing_raised do
      xls = ProblemReport.to_xls(@project.id)

      assert_not_equals_nil(xls, 'XLS Data', '    Expect XLS Data to not be nil. It was.')
    end

    STDERR.puts('    The Problem Report generated XLS successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the Problem Report can assign columns properly.')

    pr = ProblemReport.new()

    assert(pr.assign_column('id', '1', @project.id))
    assert(pr.assign_column('project_id', 'Test', @project.id))
    assert_equals(@project.id, pr.project_id, 'Project ID',
                  "    Expect Project ID to be #{@project.id}. It was.")
    assert(pr.assign_column('item_id', 'HARDWARE_ITEM', @project.id))
    assert(pr.assign_column('prid', @problem_report.prid.to_s,
                            @project.id))
    assert_equals(@problem_report.prid, pr.prid, 'Problem Report ID',
                  "    Expect Problem ID to be #{@problem_report.prid}. It was.")
    assert(pr.assign_column('dateopened', @problem_report.dateopened.to_s,
                            @project.id))
    assert(pr.assign_column('status', @problem_report.status,
                            @project.id))
    assert_equals(@problem_report.status, pr.status, 'Status',
                  "    Expect Status to be #{@problem_report.status}. It was.")
    assert(pr.assign_column('openedby', @problem_report.openedby,
                            @project.id))
    assert_equals(@problem_report.openedby, pr.openedby, 'Opened By',
                  "    Expect Opened By to be #{@problem_report.openedby}. It was.")
    assert(pr.assign_column('title', @problem_report.title,
                            @project.id))
    assert_equals(@problem_report.title, pr.title, 'Title',
                  "    Expect Title to be #{@problem_report.title}. It was.")
    assert(pr.assign_column('product', @problem_report.product,
                            @project.id))
    assert_equals(@problem_report.product, pr.product, 'Product',
                  "    Expect Product to be #{@problem_report.product}. It was.")
    assert(pr.assign_column('criticality', @problem_report.criticality,
                            @project.id))
    assert_equals(@problem_report.criticality, pr.criticality, 'Criticality',
                  "    Expect Criticality to be #{@problem_report.criticality}. It was.")
    assert(pr.assign_column('source', @problem_report.source,
                            @project.id))
    assert_equals(@problem_report.source, pr.source, 'Source',
                  "    Expect Source to be #{@problem_report.source}. It was.")
    assert(pr.assign_column('discipline_assigned', @problem_report.discipline_assigned,
                            @project.id))
    assert_equals(@problem_report.discipline_assigned, pr.discipline_assigned, 'Discipline_assigned',
                  "    Expect Discipline_assigned to be #{@problem_report.discipline_assigned}. It was.")
    assert(pr.assign_column('assignedto', @problem_report.assignedto,
                            @project.id))
    assert_equals(@problem_report.assignedto, pr.assignedto, 'Assignedto',
                  "    Expect Assignedto to be #{@problem_report.assignedto}. It was.")
    assert(pr.assign_column('target_date', @problem_report.target_date.to_s,
                            @project.id))
    assert(pr.assign_column('close_date', @problem_report.close_date.to_s,
                            @project.id))
    assert(pr.assign_column('description', @problem_report.description,
                            @project.id))
    assert_equals(@problem_report.description, pr.description, 'Description',
                  "    Expect Description to be #{@problem_report.description}. It was.")
    assert(pr.assign_column('problemfoundin', @problem_report.problemfoundin,
                            @project.id))
    assert_equals(@problem_report.problemfoundin, pr.problemfoundin, 'Problemfoundin',
                  "    Expect Problemfoundin to be #{@problem_report.problemfoundin}. It was.")
    assert(pr.assign_column('correctiveaction', @problem_report.correctiveaction,
                            @project.id))
    assert_equals(@problem_report.correctiveaction, pr.correctiveaction, 'Correctiveaction',
                  "    Expect Correctiveaction to be #{@problem_report.correctiveaction}. It was.")
    assert(pr.assign_column('fixed_in', @problem_report.fixed_in,
                            @project.id))
    assert_equals(@problem_report.fixed_in, pr.fixed_in, 'Fixed_in',
                  "    Expect Fixed_in to be #{@problem_report.fixed_in}. It was.")
    assert(pr.assign_column('verification', @problem_report.verification,
                            @project.id))
    assert_equals(@problem_report.verification, pr.verification, 'Verification',
                  "    Expect Verification to be #{@problem_report.verification}. It was.")
    assert(pr.assign_column('feedback', @problem_report.feedback,
                            @project.id))
    assert_equals(@problem_report.feedback, pr.feedback, 'Feedback',
                  "    Expect Feedback to be #{@problem_report.feedback}. It was.")
    assert(pr.assign_column('notes', @problem_report.notes,
                            @project.id))
    assert_equals(@problem_report.notes, pr.notes, 'Notes',
                  "    Expect Notes to be #{@problem_report.notes}. It was.")
    assert(pr.assign_column('meeting_id', @problem_report.meeting_id,
                            @project.id))
    assert_equals(@problem_report.meeting_id, pr.meeting_id, 'Meeting_id',
                  "    Expect Meeting_id to be #{@problem_report.meeting_id}. It was.")
    assert(pr.assign_column('safetyrelated', 'true', @project.id))
    assert_equals(true, pr.safetyrelated, 'Safety Related',
                  "    Expect Safety Related from 'true' to be true. It was.")
    assert(pr.assign_column('safetyrelated', 'false', @project.id))
    assert_equals(false, pr.safetyrelated, 'Safety Related',
                  "    Expect Safety Related from 'false' to be false. It was.")
    assert(pr.assign_column('safetyrelated', 'yes', @project.id))
    assert_equals(true, pr.safetyrelated, 'Safety Related',
                  "    Expect Safety Related from 'yes' to be true. It was.")
    assert(pr.assign_column('datemodified', @problem_report.datemodified.to_s,
                            @project.id))
    assert(pr.assign_column('archive_id', 'Test', @problem_report.archive_id))
    assert_equals(@problem_report.archive_id, pr.archive_id, 'Archive ID',
                  "    Expect Archive ID to be #{@problem_report.archive_id}. It was.")
    assert(pr.assign_column('referenced_artifacts', @problem_report.referenced_artifacts.to_json,
                            @project.id))
    assert_equals(@problem_report.referenced_artifacts, pr.referenced_artifacts, 'Referenced_artifacts',
                  "    Expect Referenced_artifacts to be #{@problem_report.referenced_artifacts}. It was.")
    assert(pr.assign_column('archive_revision', 'a', @project.id))
    assert(pr.assign_column('archive_version', '1.1', @project.id))
    STDERR.puts('    The Problem Report assigned the columns successfully.')
  end

  test 'should parse CSV string' do
    STDERR.puts('    Check to see that the Problem Report can parse CSV properly.')

    attributes = [
                    'project_id',
                    'item_id',
                    'status',
                    'openedby',
                    'title',
                    'product',
                    'criticality',
                    'source',
                    'discipline_assigned',
                    'assignedto',
                    'problemfoundin',
                    'correctiveaction',
                    'fixed_in',
                    'verification',
                    'meeting_id',
                    'safetyrelated',
                    'referenced_artifacts'
                 ]
    csv        = ProblemReport.to_csv(@project.id)
    lines      = csv.split("\n")

    assert_equals(:duplicate_problem_report,
                  ProblemReport.from_csv_string(lines[1],
                                                    @project,
                                                    [ :check_duplicates ]),
                  'Problem Report Records',
                  '    Expect Duplicate Problem Report Records to error. They did.')

    line       = lines[1].sub(',1,', ',4,')

    assert(ProblemReport.from_csv_string(line, @project))

    sysreq        = ProblemReport.find_by(prid: 4)

    assert_equals(true, compare_prs(@problem_report, sysreq, attributes),
                  'Problem Report Records',
                  '    Expect Problem Report Records to match. They did.')
    STDERR.puts('    The Problem Report parsed CSV successfully.')
  end

  test 'should parse files' do
    STDERR.puts('    Check to see that the Problem Report can parse files properly.')
    assert_equals(:duplicate_problem_report,
                  ProblemReport.from_file('test/fixtures/files/Test-Problem_Reports.csv',
                                              @project,
                                              [ :check_duplicates ]),
                  'Problem Report Records from Test-Problem_Reports.csv',
                  '    Expect Duplicate Problem Report Records to error. They did.')
    assert_equals(true,
                  ProblemReport.from_file('test/fixtures/files/Test-Problem_Reports.csv',
                                              @project),
                  'Problem Report Records From Test-Problem_Reports.csv',
                  '    Expect Changed Problem Report Associations Records  from Test-Problem_Reports.csv to error. They did.')
    assert_equals(:duplicate_problem_report,
                  ProblemReport.from_file('test/fixtures/files/Test-Problem_Reports.xls',
                                              @project,
                                              [ :check_duplicates ]),
                  'Problem Report Records from Test-Problem_Reports.csv',
                  '    Expect Duplicate Problem Report Records to error. They did.')
    assert_equals(true,
                  ProblemReport.from_file('test/fixtures/files/Test-Problem_Reports.xls',
                                              @project),
                  'Problem Report Records From Test-Problem_Reports.csv',
                  '    Expect Changed Problem Report Associations Records  from Test-Problem_Reports.csv to error. They did.')
    assert_equals(:duplicate_problem_report,
                  ProblemReport.from_file('test/fixtures/files/Test-Problem_Reports.xlsx',
                                              @project,
                                              [ :check_duplicates ]),
                  'Problem Report Records from Test-Problem_Reports.csv',
                  '    Expect Duplicate Problem Report Records to error. They did.')
    assert_equals(true,
                  ProblemReport.from_file('test/fixtures/files/Test-Problem_Reports.xlsx',
                                              @project),
                  'Problem Report Records From Test-Problem_Reports.csv',
                  '    Expect Changed Problem Report Associations Records  from Test-Problem_Reports.csv to error. They did.')
    STDERR.puts('    The Problem Report parsed files successfully.')
  end
end

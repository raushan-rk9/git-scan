require 'test_helper'

class ChecklistItemTest < ActiveSupport::TestCase
  setup do
    @project        = Project.find_by(identifier: 'TEST')
    @review         = Review.find_by(reviewid: 1)
    @checklist_item = ChecklistItem.find_by(clitemid: 23)

    user_pm
  end

  test 'should create checklist item' do
    STDERR.puts('    Check to see that a Checklist Item can be created.')
    checklist_item = ChecklistItem.new({
                                          clitemid:    @checklist_item.clitemid + 1,
                                          description: @checklist_item.description,
                                          reference:   @checklist_item.reference,
                                          minimumdal:  @checklist_item.minimumdal,
                                          supplements: @checklist_item.supplements,
                                          evaluator:   @checklist_item.evaluator,
                                          user_id:     @checklist_item.user_id,
                                          assigned:    @checklist_item.assigned,
                                          review_id:   @checklist_item.review_id
                                       })

    assert_not_equals_nil(checklist_item.save, 'Checklist Item Record', '    Expect Checklist Item Record to be created. It was.')
    STDERR.puts('    An Checklist Item was successfully created.')
  end

  test 'should update Checklist Item' do
    STDERR.puts('    Check to see that an Checklist Item can be updated.')

    @checklist_item.clitemid += 1

    assert_not_equals_nil(@checklist_item.save, 'Checklist Item Record', '    Expect Checklist Item Record to be updated. It was.')
    STDERR.puts('    An Checklist Item was successfully updated.')
  end

  test 'should delete Checklist Item' do
    STDERR.puts('    Check to see that an Checklist Item can be deleted.')
    assert(@checklist_item.destroy)
    STDERR.puts('    An Checklist Item was successfully deleted.')
  end

  test 'should create Checklist Item with undo/redo' do
    STDERR.puts('    Check to see that an Checklist Item can be created, then undone and then redone.')
    checklist_item = ChecklistItem.new({
                                          clitemid:    @checklist_item.clitemid + 1,
                                          description: @checklist_item.description,
                                          reference:   @checklist_item.reference,
                                          minimumdal:  @checklist_item.minimumdal,
                                          supplements: @checklist_item.supplements,
                                          evaluator:   @checklist_item.evaluator,
                                          user_id:     @checklist_item.user_id,
                                          assigned:    @checklist_item.assigned,
                                          review_id:   @checklist_item.review_id
                                       })
    data_change    = DataChange.save_or_destroy_with_undo_session(checklist_item, 'create')

    assert_not_equals_nil(data_change, 'Checklist Item Record', '    Expect Checklist Item Record to be created. It was.')

    assert_difference('ChecklistItem.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('ChecklistItem.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    An Checklist Item was successfully created, then undone and then redone.')
  end

  test 'should update Checklist Item with undo/redo' do
    STDERR.puts('    Check to see that an Checklist Item can be updated, then undone and then redone.')
    @checklist_item.clitemid += 1
    data_change               = DataChange.save_or_destroy_with_undo_session(@checklist_item, 'update')
    @checklist_item.clitemid -= 1

    assert_not_equals_nil(data_change, 'Checklist Item Record', '    Expect Checklist Item Record to be updated. It was')
    assert_not_equals_nil(ChecklistItem.find_by(clitemid: @checklist_item.clitemid + 1), 'Checklist Item Record', "    Expect Checklist Item Record's ID to be #{@checklist_item.clitemid + 1}. It was.")
    assert_equals(nil, ChecklistItem.find_by(clitemid: @checklist_item.clitemid), 'Checklist Item Record', '    Expect original Checklist Item Record not to be found. It was not found.')
    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, ChecklistItem.find_by(clitemid: @checklist_item.clitemid + 1), 'Checklist Item Record', "    Expect updated Checklist Item's Record not to found. It was not found.")
    assert_not_equals_nil(ChecklistItem.find_by(clitemid: @checklist_item.clitemid), 'Checklist Item Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(ChecklistItem.find_by(clitemid: @checklist_item.clitemid + 1), 'Checklist Item Record', "    Expect updated Checklist Item's Record to be found. It was found.")
    assert_equals(nil, ChecklistItem.find_by(clitemid: @checklist_item.clitemid), 'Checklist Item Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    An Checklist Item was successfully updated, then undone and then redone.')
  end

  test 'should delete Checklist Item with undo/redo' do
    STDERR.puts('    Check to see that an Checklist Item can be deleted, then undone and then redone.')
    data_change = DataChange.save_or_destroy_with_undo_session(@checklist_item, 'delete')

    assert_not_equals_nil(data_change, 'Checklist Item Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, ChecklistItem.find_by(clitemid: @checklist_item.clitemid), 'Checklist Item Record', '    Verify that the Checklist Item Record was actually deleted. It was.')
    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(ChecklistItem.find_by(clitemid: @checklist_item.clitemid), 'Checklist Item Record', '    Verify that the Checklist Item Record was restored after undo. It was.')
    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, ChecklistItem.find_by(clitemid: @checklist_item.clitemid), 'Checklist Item Record', '    Verify that the Checklist Item Record was deleted again after redo. It was.')
    STDERR.puts('    An Checklist Item was successfully deleted, then undone and then redone.')
  end

  test 'consolidate checklist items' do
    STDERR.puts('    Check to see that a Consolidated Checklist can be generated.')

    @consolidated_items = ChecklistItem.consolidate_checklist_items(@review.id,
                                                                    @review.checklists_assigned)

    assert_equals(23, @consolidated_items.length, 'Consolidated Checklist', '    Expect Consolidated Checklist to have 23 items. It was valid.')
    STDERR.puts('    The Consolidated Checklist was valid.')
  end

  test 'consolidate checklist items to CSV' do
    STDERR.puts('    Check to see that a Consolidated Checklist can be generated.')

    @consolidated_items = ChecklistItem.to_consolidated_csv(@review.id,
                                                            @review.checklists_assigned)
    lines               = @consolidated_items.split("\n")

    assert_equals('ID,Description,Status,Notes', lines[0], 'Consolidated Checklist', '    Expect Header to be "ID,Description,Status,Notes". It was.')
    assert_equals(24, lines.length, 'Consolidated Checklist', '    Expect Consolidated Checklist to have 24 items. It was valid.')
    STDERR.puts('    The Consolidated CSV Checklist was valid.')
  end

  test 'consolidate checklist items to XLS' do
    STDERR.puts('    Check to see that a Consolidated Checklist can be generated.')

    @consolidated_items = ChecklistItem.to_consolidated_xls(@review.id,
                                                            @review.checklists_assigned)

    assert_between(11700, 12000, @consolidated_items.length, 'Consolidated Checklist', '    Expect Consolidated Checklist to be between 11700 and 12000. It was valid.')
    STDERR.puts('    The Consolidated XLS Checklist was valid.')
  end

  test 'checklist items to CSV' do
    STDERR.puts('    Check to see that a Checklist csv file can be generated.')

    csv   = ChecklistItem.to_csv(@review.id)
    lines = csv.split("\n")

    assert_equals('clitemid,review_id,document_id,description,note,reference,minimumdal,supplements,status,evaluator,evaluation_date', lines[0], 'Consolidated Checklist', '    Expect Header to be "clitemid,review_id,document_id,description,note,reference,minimumdal,supplements,status,evaluator,evaluation_date". It was.')
    assert_equals(125, lines.length, 'Consolidated Checklist', '    Expect Consolidated Checklist to have 125 items. It was valid.')
    STDERR.puts('    The CSV Checklist was valid.')
  end

  test 'checklist items to XLS' do
    STDERR.puts('    Check to see that a Checklist xls file can be generated.')

    xls   = ChecklistItem.to_xls(@review.id)
    assert_between(11700, 12000, xls.length, 'Consolidated Checklist', '    Expect Consolidated Checklist to be between 11700 and 12000. It was valid.')
    STDERR.puts('    The XLS Checklist was valid.')
  end
  
  test 'import checklist items from CSV' do
    STDERR.puts('    Check to see that a Checklist csv file can be imported.')

    filename = Rails.root.join('tmp', 'checklist.csv')

    File.open(filename, 'w') do |output_file|
      output_file.write(ChecklistItem.to_csv(@review.id))
    end

    assert(ChecklistItem.from_file(filename.to_s))
    STDERR.puts('    The CSV Checklist was imported successfully.')
  end

  test 'import checklist items from XLS' do
    STDERR.puts('    Check to see that a Checklist xls file can be imported.')

    filename = Rails.root.join('tmp', 'checklist.xls')

    File.open(filename, 'wb') do |output_file|
      output_file.write(ChecklistItem.to_xls(@review.id))
    end

    assert(ChecklistItem.from_file(filename.to_s))
    STDERR.puts('    The XLS Checklist was imported successfully.')
  end

  test 'import checklist items from XLSX' do
    STDERR.puts('    Check to see that a Checklist xls file can be imported.')

    filename = Rails.root.join('test', 'fixtures', 'files', 'PHAC Review-Checklist-1.xlsx')

    assert(ChecklistItem.from_file(filename.to_s))
    STDERR.puts('    The XLS Checklist was imported successfully.')
  end

  test 'import checklist items from a Patmos XLSX' do
    STDERR.puts('    Check to see that a Patmos Checklist xls file can be imported.')

    filename = Rails.root.join('app', 'templates', 'do-178', 'checklists', 'peer', '1a.DO178C.Peer-Review-Checklist-Planning-PSAC.FINAL.r1a.xlsx')

    assert(ChecklistItem.from_patmos_spreadsheet(filename.to_s, @review.id))
    STDERR.puts('    The XLS Checklist was imported successfully.')
  end

  test 'should assign columns' do
    STDERR.puts('    Check to see that the Checklist item can assign columns properly.')

    checklist_item = ChecklistItem.new()

    assert(ChecklistItem.assign_column(checklist_item,
                                        'clitemid',
                                        @checklist_item.clitemid.to_s))
    assert_equals(checklist_item.clitemid,
                  @checklist_item.clitemid,
                  'clitemid',
                  "    Expect clitemid to be #{@checklist_item.clitemid}. It was.")
    assert(ChecklistItem.assign_column(checklist_item,
                                        'review_id',
                                        @checklist_item.review_id.to_s))
    assert_equals(checklist_item.review_id,
                  @checklist_item.review_id,
                  'review_id',
                  "    Expect review_id to be #{@checklist_item.review_id}. It was.")
    assert(ChecklistItem.assign_column(checklist_item,
                                        'document_id',
                                        @checklist_item.document_id.to_s))
    assert_equals(checklist_item.document_id,
                  @checklist_item.document_id,
                  'document_id',
                  "    Expect document_id to be #{@checklist_item.document_id}. It was.")
    assert(ChecklistItem.assign_column(checklist_item,
                                        'description',
                                        @checklist_item.description))
    assert_equals(checklist_item.description,
                  @checklist_item.description,
                  'description',
                  "    Expect description to be #{@checklist_item.description}. It was.")
    assert(ChecklistItem.assign_column(checklist_item,
                                        'note',
                                        @checklist_item.note))
    assert_equals(checklist_item.note,
                  @checklist_item.note,
                  'note',
                  "    Expect note to be #{@checklist_item.note}. It was.")
    assert(ChecklistItem.assign_column(checklist_item,
                                        'reference',
                                        @checklist_item.reference))
    assert_equals(checklist_item.reference,
                  @checklist_item.reference,
                  'reference',
                  "    Expect reference to be #{@checklist_item.reference}. It was.")
    assert(ChecklistItem.assign_column(checklist_item,
                                        'supplements',
                                        @checklist_item.supplements))
    assert_equals(checklist_item.supplements,
                  @checklist_item.supplements,
                  'supplements',
                  "    Expect supplements to be #{@checklist_item.supplements}. It was.")
    assert(ChecklistItem.assign_column(checklist_item,
                                        'status',
                                        @checklist_item.status))
    assert_equals(checklist_item.status,
                  @checklist_item.status,
                  'status',
                  "    Expect status to be #{@checklist_item.status}. It was.")
    assert(ChecklistItem.assign_column(checklist_item,
                                        'evaluator',
                                        @checklist_item.evaluator))
    assert_equals(checklist_item.evaluator,
                  @checklist_item.evaluator,
                  'evaluator',
                  "    Expect evaluator to be #{@checklist_item.evaluator}. It was.")
    assert(ChecklistItem.assign_column(checklist_item,
                                        'archive_revision',
                                        'a'))
    assert(ChecklistItem.assign_column(checklist_item,
                                        'archive_version',
                                        '1.1'))

    STDERR.puts('    The Checklist Item assigned the columns successfully.')
  end
end

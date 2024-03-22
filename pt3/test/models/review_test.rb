require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  Thread.current[:populate_templates] = true

  setup do
    @project = Project.find_by(identifier: 'TEST')
    @review  = Review.find_by(reviewid: 1)

    user_pm
  end

  test 'review record should be valid' do
    STDERR.puts('    Check to see that a Review Record with required fields filled in is valid.')
    assert_equals(true, @review.valid?,
                  'Review Record',
                  '    Expect Review Record to be valid. It was valid.')
    STDERR.puts('    The Review Record was valid.')
  end

  test 'review id shall be present for review' do
    STDERR.puts('    Check to see that a Review Record without a Review ID is invalid.')

    @review.reviewid = nil

    assert_equals(false, @review.valid?,
                  'Review Record',
                  '    Expect Review without review_id not to be valid. It was not valid.')
    STDERR.puts('    The Review Record was invalid.')
  end

  test 'project id shall be present for review attchment' do
    STDERR.puts('    Check to see that a Review Record without a Project ID is invalid.')

    @review.project_id = nil

    assert_equals(false, @review.valid?,
                  'Review Record',
                  '    Expect Project without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Review Record was invalid.')
  end

  test 'item id shall be present for review attchment' do
    STDERR.puts('    Check to see that a Review Record without an Item ID is invalid.')

    @review.item_id = nil

    assert_equals(false, @review.valid?,
                  'Review Record',
                  '    Expect Project without project_id not to be valid. It was not valid.')
    STDERR.puts('    The Review Record was invalid.')
  end

  test 'title shall be present for review' do
    STDERR.puts('    Check to see that a Review Record without a title ID is invalid.')
    @review.title = nil

    assert_equals(false, @review.valid?,
                  'Review Record',
                  '    Expect Review without title not to be valid. It was not valid.')
    STDERR.puts('    The Review Record was invalid.')
  end

# We implement CRUD Testing by default. The Read Action is implicit in setup.

  test "Create Review" do
    STDERR.puts('    Check to see that a Review can be created.')

    review = Review.new({
                              reviewid:            @review.reviewid + 2,
                              reviewtype:          @review.reviewtype,
                              title:               @review.title,
                              evaluators:          @review.evaluators,
                              evaldate:            @review.evaldate,
                              description:         @review.description,
                              version:             @review.version,
                              item_id:             @review.item_id,
                              project_id:          @review.project_id,
                              clitem_count:        @review.clitem_count,
                              ai_count:            @review.ai_count,
                              organization:        @review.organization,
                              attendees:           @review.attendees,
                              checklists_assigned: @review.checklists_assigned,
                              upload_date:         @review.upload_date
                            })

    assert_not_equals_nil(review.save, 'Review Record', '    Expect Review Record to be created. It was.')
    STDERR.puts('    A Review was successfully created.')
  end

  test "Update Review" do
    STDERR.puts('    Check to see that a Review can be updated.')

    @review.reviewid += 2

    assert_not_equals_nil(@review.save, 'Review Record', '    Expect Review Record to be updated. It was.')
    STDERR.puts('    A Review was successfully updated.')
  end

  test "Delete Review" do
    STDERR.puts('    Check to see that a Review can be deleted.')
    assert(@review.destroy)
    assert_equals(nil, Review.find_by(reviewid: 1), 'Review Record', '    Expect original Review Record not to be found. It was not found.')
    STDERR.puts('    A Review was successfully deleted.')
  end

  test "Undo/Redo Create Review" do
    STDERR.puts('    Check to see that a Review can be created, then undone and then redone.')

    review = Review.new({
                              reviewid:            @review.reviewid + 2,
                              reviewtype:          @review.reviewtype,
                              title:               @review.title,
                              evaluators:          @review.evaluators,
                              evaldate:            @review.evaldate,
                              description:         @review.description,
                              version:             @review.version,
                              item_id:             @review.item_id,
                              project_id:          @review.project_id,
                              clitem_count:        @review.clitem_count,
                              ai_count:            @review.ai_count,
                              organization:        @review.organization,
                              attendees:           @review.attendees,
                              checklists_assigned: @review.checklists_assigned,
                              upload_date:         @review.upload_date
                            })
    data_change    = DataChange.save_or_destroy_with_undo_session(review, 'create')

    assert_not_equals_nil(data_change, 'Review Record', '    Expect Review Record to be created. It was.')

    assert_difference('Review.count', -1) do
      ChangeSession.undo(data_change.session_id)
    end

    assert_difference('Review.count', +1) do
      ChangeSession.redo(data_change.session_id)
    end

    STDERR.puts('    A Review was successfully created, then undone and then redone.')
  end

  test "Undo/Redo Update Review" do
    STDERR.puts('    Check to see that a Review can be updated, then undone and then redone.')

    @review.reviewid = 3
    data_change      = DataChange.save_or_destroy_with_undo_session(@review, 'update')

    assert_not_equals_nil(data_change, 'Review Record', '    Expect Review Record to be updated. It was')
    assert_not_equals_nil(Review.find_by(reviewid: 3), 'Review Record', "    Expect Review Record's ID to be 3. It was.")
    assert_equals(nil, Review.find_by(reviewid: 1), 'Review Record', '    Expect original Review Record not to be found. It was not found.')

    ChangeSession.undo(data_change.session_id)
    assert_equals(nil, Review.find_by(reviewid: 3), 'Review Record', "    Expect updated Review's Record not to found. It was not found.")
    assert_not_equals_nil(Review.find_by(reviewid: 1), 'Review Record', '    Expect Orginal Record to be found. it was found.')
    ChangeSession.redo(data_change.session_id)
    assert_not_equals_nil(Review.find_by(reviewid: 3), 'Review Record', "    Expect updated Review's Record to be found. It was found.")
    assert_equals(nil, Review.find_by(reviewid: 1), 'Review Record', '    Expect Orginal Record not to be found. It was not found.')
    STDERR.puts('    A Review was successfully updated, then undone and then redone.')
  end

  test "Undo/Redo Delete Review" do
    STDERR.puts('    Check to see that a Review can be deleted, then undone and then redone.')

    data_change = DataChange.save_or_destroy_with_undo_session(@review, 'delete')

    assert_not_equals_nil(data_change, 'Review Record', '    Expect that the delete succeded. It did.')
    assert_equals(nil, Review.find_by(reviewid: @review.reviewid), 'Review Record', '    Verify that the Review Record was actually deleted. It was.')

    ChangeSession.undo(data_change.session_id)
    assert_not_equals_nil(Review.find_by(reviewid: @review.reviewid), 'Review Record', '    Verify that the Review Record was restored after undo. It was.')

    ChangeSession.redo(data_change.session_id)
    assert_equals(nil, Review.find_by(reviewid: @review.reviewid), 'Review Record', '    Verify that the Review Record was deleted again after redo. It was.')
    STDERR.puts('    A Review was successfully deleted, then undone and then redone.')
  end

  test "fullreviewid" do
    STDERR.puts('    Check to see that the Review returns a proper Full ID.')
    assert_equals('HARDWARE_ITEM-REVIEW-1', @review.fullreviewid, 'Review Full ID', '    Verify that the Review Full ID is HARDWARE_ITEM-REVIEW-1. It was.')
    STDERR.puts('    The Review returned a proper Full ID successfully.')
  end

  test "actionitems_open" do
    STDERR.puts('    Check to see that the Review returns the open action item count correctly.')
    assert_equals(1, @review.actionitems_open, 'Open Action Items', '    Verify that the Open Action Items are 1. It was.')
    STDERR.puts('    The Review returned the open action item count correctly.')
  end

  test "evaluators_assigned" do
    STDERR.puts('    Check to see that the Review returns the number of evaluators assigned correctly.')
    assert_equals(1, @review.actionitems_open, 'Evaluators Assigned', '    Verify that the Evaluators Assigned are 1. It was.')
    STDERR.puts('    The Review returned the number of evaluators assigned correctly.')
  end

  test "checklistitems_unassigned" do
    STDERR.puts('    Check to see that the Review returns the number of check list items unassigned correctly.')
    assert_equals(0, @review.checklistitems_unassigned, 'ChecklistItems Unassigned', '    Verify that the ChecklistItems Unassigned are 0. It was.')
    STDERR.puts('    The Review returned the number of check list items unassigned correctly.')
  end

  test "checklistitems_assigned" do
    STDERR.puts('    Check to see that the Review returns the number of check list items assigned correctly.')
    assert_equals(23, @review.checklistitems_assigned, 'ChecklistItems Assigned', '    Verify that the ChecklistItems Assigned are 0. It was.')
    STDERR.puts('    The Review returned the number of check list items assigned correctly.')
  end

  test "checklistitems_totalnumber" do
    STDERR.puts('    Check to see that the Review returns the total number of check list items correctly.')
    assert_equals(23, @review.checklistitems_totalnumber, 'Total Number of Checklist Items', '    Verify that the Total Number of Checklist Items are 0. It was.')
    STDERR.puts('    The Review returned the total number of check list items correctly.')
  end

  test "checklistitems_passingnumber" do
    STDERR.puts('    Check to see that the Review returns the number of check list items passing correctly.')
    assert_equals(0, @review.checklistitems_passingnumber, 'Number of Passing Checklist Items', '    Verify that the Total Number of Passing Checklist Items are 0. It was.')
    STDERR.puts('    The Review returned the number of check list items passing correctly.')
  end

  test "checklistitems_failingnumber" do
    STDERR.puts('    Check to see that the Review returns the number of check list items failing correctly.')
    assert_equals(0, @review.checklistitems_failingnumber, 'Number of Failing Checklist Items', '    Verify that the Total Number of Failing Checklist Items are 0. It was.')
    STDERR.puts('    The Review returned the number of check list items failing correctly.')
  end

  test "checklistitems_na_number" do
    STDERR.puts('    Check to see that the Review returns the number of N/A list check list items correctly.')
    assert_equals(0, @review.checklistitems_failingnumber, 'Number of N/A Checklist Items', '    Verify that the Total Number of N/A Checklist Items are 0. It was.')
    STDERR.puts('    The Review returned the number of N/A check list items correctly.')
  end

  test "checklistitems_neithernumber" do
    STDERR.puts('    Check to see that the Review returns the number of unreported check list items correctly.')
    assert_equals(23, @review.checklistitems_neithernumber, 'Number of Unreported Checklist Items', '    Verify that the Total Number of Unreported Checklist Items are 0. It was.')
    STDERR.puts('    The Review returned the number of unreported check list items correctly.')
  end

  test "checklistitems_percentage_completed" do
    STDERR.puts('    Check to see that the Review returns the percentage of check list items completed correctly.')
    assert_equals(0.0, @review.checklistitems_percentage_completed, 'Percentage of Complete Checklist Items', '    Verify that the Percentage of Complete Checklist Items are 0.0. It was.')
    STDERR.puts('    The Review returned the percentage of check list items completed correctly.')
  end

  test "checklistitems_percentage_incomplete" do
    STDERR.puts('    Check to see that the Review returns the percentage of incomplete check list items correctly.')
    assert_equals(100.0, @review.checklistitems_percentage_incomplete, 'Percentage of Incomplete Checklist Items', '    Verify that the Percentage of Incomplete Checklist Items are 0.0. It was.')
    STDERR.puts('    The Review returned the percentage of incomplete check list items correctly.')
  end

  test "checklistitems_passing" do
    STDERR.puts('    Check to see that the Review returns the number of check list items passing correctly.')
    assert_equals(0, @review.checklistitems_passingnumber, 'Checklist Items Passing', '    Verify that the Checklist Items Passing is false. It was.')
    STDERR.puts('    The Review returned the number of check list items passing correctly.')
  end

  test "review_passing" do
    STDERR.puts('    Check to see that the Review returns the status of the review correctly.')
    assert_equals(false, @review.review_passing, 'Review Passing', '    Verify that the Review Passing is false. It was.')
    STDERR.puts('    The Review returned the status of the review correctly.')
  end

  test "Review.to_csv" do
    STDERR.puts('    Check to see that the Review can generate CSV correctly.')
    assert_equals("id,reviewid,reviewtype,title,description,version,item,project\n9197371,2,Plan for Software Aspects of Certification,PSAC Review,Review Plan for Software Aspects of Certification,1,\"\",\"\"\n", Review.to_csv, 'Review CSV', '    Verify that the Review CSV was correct. It was.')
    STDERR.puts('    The Review generated CSV correctly.')
  end
end

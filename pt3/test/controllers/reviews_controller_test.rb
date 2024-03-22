require 'test_helper'

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  Thread.current[:populate_templates] = true

  setup do
    @review  = Review.find_by(reviewid: 1)
    @item     = Item.find(@review.item_id)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Review List Page can be loaded.')
    get item_reviews_url(@item)
    assert_response :success
    STDERR.puts('    The Review List Page loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that the New Review Page can be loaded.')
    get new_item_review_url(@item)
    assert_response :success
    STDERR.puts('    The New Review Page loaded successfully.')
  end

  test "should create review" do
    STDERR.puts('    Check to see that a Review can be created.')

    assert_difference('Review.count') do
      post item_reviews_url(@item),
        params:
        {
          review:
          {
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
          }
        }
    end

    assert_redirected_to item_review_url(@item, Review.last)
    STDERR.puts('    The Review was created successfully.')
  end

  test "should show review" do
    STDERR.puts('    Check to see that a Review can be viewed.')
    get item_review_url(@item, @review)
    assert_response :success
    STDERR.puts('    The Review was viewed successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit Review Page can be loaded.')
    get edit_item_review_url(@item, @review)
    assert_response :success
    STDERR.puts('    The Edit Review page loaded successfully.')
  end

  test "should update review" do
    STDERR.puts('    Check to see that a Review can be updated.')

    new_id = @review.reviewid + 2

    patch item_review_url(@item, @review,
      params:
      {
        review:
        {
          reviewid:            new_id,
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
        }
      })

    assert_redirected_to item_review_url(@item, @review)
    STDERR.puts('    The Review was successfully updated.')
  end

  test "should destroy review" do
    STDERR.puts('    Check to see that a Review can be deleted.')

    assert_difference('Review.count', -1) do
      delete item_review_url(@item, @review)
    end

    assert_redirected_to item_reviews_url(@item)
    STDERR.puts('    The Review was successfully deleted.')
  end

  test "should get cl_fill" do
    STDERR.puts('    Check to see that checklist items can be filled.')

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
                              clitem_count:        0,
                              ai_count:            @review.ai_count,
                              organization:        @review.organization,
                              attendees:           @review.attendees,
                              checklists_assigned: false,
                              upload_date:         @review.upload_date
                            })

    review.save!
    get review_checklistfill_path(review)
    assert_response :success
    STDERR.puts('    Checklist items were can be filled successfully.')
  end

  test "should get cl_removeall" do
    STDERR.puts('    Check to see that checklist items can be removed.')

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
                              clitem_count:        0,
                              ai_count:            @review.ai_count,
                              organization:        @review.organization,
                              attendees:           @review.attendees,
                              checklists_assigned: false,
                              upload_date:         @review.upload_date
                            })

    review.save!
    get review_checklistremoveall_path(review)
    assert_response :success
    STDERR.puts('    Checklist items were successfully removed.')
  end

  test "should get signin" do
    STDERR.puts('    Check to see that a Signin Page can be loaded.')
    get review_sign_in_url(@review)
    assert_response :success
    STDERR.puts('    The Signin page loaded successfully.')
  end

  test "should save signin" do
    STDERR.puts('    Check to see that a Signin Page can be loaded.')
    get review_save_sign_in_url(@review)
    assert_response :success
    assert_equals('%PDF-', response.body[0..4], 'Signing PDF Header', "    Expect Signing PDF header to be %PDF-. It was")
    STDERR.puts('    The Signin page loaded successfully.')
  end

  test "should select attendees" do
    STDERR.puts('    Check to see that a Select Attendees Page can be loaded.')
    get review_select_attendees_url(@review)
    assert_response :success
    STDERR.puts('    The Select Attendees page loaded successfully.')
  end

  test "should signoff" do
    STDERR.puts('    Check to see that a an Attendee can signoff.')
    get review_sign_off_url(@review)
    assert_redirected_to review_sign_in_url(@review)
    STDERR.puts('    An Attendee signed off successfully.')
  end

  test "should assign checklists" do
    STDERR.puts('    Check to see that checklists can be assigned.')
    get review_assign_checklists_url(@review)
    assert_redirected_to item_review_url(@item, Review.last)
    STDERR.puts('    Checklists were assigned successfully.')
  end

  test "get fillin checklists" do
    STDERR.puts('    Check to see that a Fill-in Checklist Page can be loaded.')
    get review_fill_in_checklist_url(@review)
    assert_response :success
    STDERR.puts('    Fill-in Checklist Page was loaded successfully.')
  end

  test "submit checklists" do
    STDERR.puts('    Check to see that a Fill-in Checklist Page can be submitted.')
    post review_fill_in_checklist_url(@review,
      params:
      {
        checklist_data: '
          [
            {
              "id" :     "1",
              "status": "Pass",
              "notes":  ""
            },
            {
              "id":     "2",
              "status": "Fail",
              "notes":  "Did not work."
            }
          ]
        '
      })

    assert_redirected_to item_review_url(@item, Review.last)
    STDERR.puts('    Fill-in Checklist Page was submitted successfully.')
  end

  test "get consolidated checklists" do
    STDERR.puts('    Check to see that a Consolidated Checklist Page can be loaded.')
    get review_consolidated_checklist_url(@review)
    assert_response :success
    STDERR.puts('    Consolidated Checklist Page was loaded successfully.')
  end

  test "get checklist" do
    STDERR.puts('    Check to see that a Checklist Page can be loaded.')
    get review_checklist_url(@review)
    assert_response :success
    STDERR.puts('    Checklist Page was loaded successfully.')
  end

  test "export checklist" do
    STDERR.puts('    Check to see that a Checklist can be exported.')
    put review_export_checklist_url(@review, checklist_export: { export_type: 'CSV' })

    lines = response.body.split("\n")

    assert_equals("#,Checklist Item,DO-178C or Other Guidance Reference,DAL,Supplements,Compliance,Remarks", lines[5], 'Header', "    Expect Header to be '#,Checklist Item,DO-178C or Other Guidance Reference,DAL,Supplements,Compliance,Remarks'. It was.")
    STDERR.puts('    Checklist was successfully exported.')
  end

  test "export consolidated checklist" do
    STDERR.puts('    Check to see that a Consolidated Checklist can be exported.')
    put review_export_consolidated_checklist_url(@review, consolidated_checklist_export: { export_type: 'CSV' })

    lines = response.body.split("\n")

    assert_equals("ID,Description,Status,Notes", lines[0], 'Header', "    Expect Header to be 'ID,Description,Status,Notes'. It was.")
    STDERR.puts('    Consolidated Checklist was successfully exported.')
  end
end

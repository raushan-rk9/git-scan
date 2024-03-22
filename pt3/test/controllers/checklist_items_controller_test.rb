require 'test_helper'

class ChecklistItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project        = Project.find_by(identifier: 'TEST')
    @review         = Review.find_by(reviewid: 1)
    @checklist_item = ChecklistItem.find_by(clitemid: 23)
    @hardware_item  = Item.find_by(identifier: 'HARDWARE_ITEM')

    user_pm
  end

  test "should get checklist item list" do
    STDERR.puts('    Check to see that we can get a checklist items list.')
    get review_checklist_url(@review)
    assert_response :success
    STDERR.puts('    Successfully retrieved a checklist items list.')
  end

  test "should get show" do
    STDERR.puts('    Check to see that we can show a checklist item.')
    get review_checklist_item_url(@review, @checklist_item)
    assert_response :success
    STDERR.puts('    Successfully showed a checklist item.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that we can get a new checklist item.')
    get new_review_checklist_item_url(@review, @checklist_item)
    assert_response :success
    STDERR.puts('    Successfully got a new checklist item.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that we can edit a checklist item.')
    get edit_review_checklist_item_url(@review, @checklist_item)
    assert_response :success
    STDERR.puts('    Successfully edited a checklist item.')
  end

  test "should create checklist item" do
    STDERR.puts('    Check to see that a Checklist Item can be created.')

    assert_difference('ChecklistItem.count') do
      post url_for(:controller => 'checklist_items', :action => 'create', :review_id => @review.id),
        params:
        {
          checklist_item:
          {
            clitemid:    @checklist_item.clitemid + 1,
            description: @checklist_item.description,
            reference:   @checklist_item.reference,
            minimumdal:  @checklist_item.minimumdal,
            supplements: @checklist_item.supplements,
            evaluator:   @checklist_item.evaluator,
            user_id:     @checklist_item.user_id,
            assigned:    @checklist_item.assigned,
            review_id:   @checklist_item.review_id
          }
        }
    end

    assert_redirected_to item_review_url(@hardware_item, @review)
    STDERR.puts('    A Checklist Item was succesfully created.')
  end

  test "should update checklist_item" do
    STDERR.puts('    Check to see that an Checklist Item can be updated.')

    patch review_checklist_item_url(@review, @checklist_item),
      params:
      {
        checklist_item:
        {
          clitemid:    @checklist_item.clitemid + 1,
          description: @checklist_item.description,
          reference:   @checklist_item.reference,
          minimumdal:  @checklist_item.minimumdal,
          supplements: @checklist_item.supplements,
          evaluator:   @checklist_item.evaluator,
          user_id:     @checklist_item.user_id,
          assigned:    @checklist_item.assigned,
          review_id:   @checklist_item.review_id
        }
      }

    assert_redirected_to item_review_url(@hardware_item, @review)
    STDERR.puts('    A Checklist Item was succesfully updated.')
  end

  test "should destroy checklist_item" do
    STDERR.puts('    Check to see that an Checklist Item can be deleted.')

    assert_difference('ChecklistItem.count', -1) do
      delete review_checklist_item_url(@review, @checklist_item)
    end

    assert_redirected_to item_review_url(@hardware_item, @review)
    STDERR.puts('    A Checklist Item was succesfully deleted.')
  end
end

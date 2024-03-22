require 'test_helper'

class ActionItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @project         = Project.find_by(identifier: 'TEST')
    @hardware_item   = Item.find_by(identifier: 'HARDWARE_ITEM')
    @software_item   = Item.find_by(identifier: 'SOFTWARE_ITEM')
    @hardware_ai_001 = ActionItem.find_by(actionitemid: 1,
                                          item_id:      @hardware_item.id)
    @software_ai_001 = ActionItem.find_by(actionitemid: 1,
                                          item_id:      @software_item.id)
    @hardware_review = Review.find_by(reviewid: 1,
                                      item_id:      @hardware_item.id)
    @software_review = Review.find_by(reviewid: 2,
                                      item_id:      @software_item.id)

    user_pm
  end

  test "should get index" do
    STDERR.puts('    Check to see that the Action Items List Page can be loaded.')
    get review_action_items_url(@hardware_review)
    assert_response :success
    STDERR.puts('    The Action Items  List Page loaded successfully.')
  end

  test "should show action_item" do
    STDERR.puts('    Check to see that a Action Item can be viewed.')
    get review_action_item_url(@hardware_review, @hardware_ai_001)
    assert_response :success
    STDERR.puts('    The Action Item view loaded successfully.')
  end

  test "should get new" do
    STDERR.puts('    Check to see that a new Action Item Page can be loaded.')
    get new_review_action_item_url(@hardware_review)
    assert_response :success
    STDERR.puts('    A new Action Item Page loaded successfully.')
  end

  test "should get edit" do
    STDERR.puts('    Check to see that a Edit Action Item Page can be loaded.')
    get edit_review_action_item_url(@hardware_review, @hardware_ai_001)
    assert_response :success
    STDERR.puts('    The Edit Action Item page loaded successfully.')
  end

  test "should create action_item" do
    STDERR.puts('    Check to see that an Action Item can be created.')

    assert_difference('ActionItem.count') do
      post review_action_items_url(@hardware_review),
        params:
        {
          action_item:
          {
            actionitemid: @hardware_ai_001.actionitemid + 1,
            description:  @hardware_ai_001.description,
            openedby:     @hardware_ai_001.openedby,
            assignedto:   @hardware_ai_001.assignedto,
            status:       @hardware_ai_001.status,
            note:         @hardware_ai_001.note,
            project_id:   @hardware_ai_001.project_id,
            item_id:      @hardware_ai_001.item_id,
            review_id:    @hardware_ai_001.review_id
          }
        }
    end

    assert_redirected_to review_action_item_url(@hardware_review, ActionItem.last)
    STDERR.puts('    An Action Item was succesfully created.')
  end

  test "should update action_item" do
    STDERR.puts('    Check to see that an Action Item can be updated.')

    patch review_action_item_url(@hardware_review, @hardware_ai_001),
      params:
      {
        action_item:
        {
          actionitemid: @hardware_ai_001.actionitemid + 1,
          description:  @hardware_ai_001.description,
          openedby:     @hardware_ai_001.openedby,
          assignedto:   @hardware_ai_001.assignedto,
          status:       @hardware_ai_001.status,
          note:         @hardware_ai_001.note,
          project_id:   @hardware_ai_001.project_id,
          item_id:      @hardware_ai_001.item_id,
          review_id:    @hardware_ai_001.review_id
        }
      }

    assert_redirected_to review_action_item_url(@hardware_review, @hardware_ai_001)
    STDERR.puts('    An Action Item was sucessfully updated.')
  end

  test "should destroy action_item" do
    STDERR.puts('    Check to see that an Action Item can be deleted.')

    assert_difference('ActionItem.count', -1) do
      delete review_action_item_url(@hardware_review, @hardware_ai_001)
    end

    assert_redirected_to review_action_items_url(@hardware_review)
    STDERR.puts('    An Action Item was successfully deleted.')
  end
end

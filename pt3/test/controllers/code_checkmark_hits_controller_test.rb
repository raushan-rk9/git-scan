require 'test_helper'

class CodeCheckmarkHitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @code_checkmark_hit = code_checkmark_hits(:one)
  end

  test "should get index" do
    get code_checkmark_hits_url
    assert_response :success
  end

  test "should get new" do
    get new_code_checkmark_hit_url
    assert_response :success
  end

  test "should create code_checkmark_hit" do
    assert_difference('CodeCheckmarkHit.count') do
      post code_checkmark_hits_url, params: { code_checkmark_hit: { code_checkmark_id: @code_checkmark_hit.code_checkmark_id, hit_at: @code_checkmark_hit.hit_at } }
    end

    assert_redirected_to code_checkmark_hit_url(CodeCheckmarkHit.last)
  end

  test "should show code_checkmark_hit" do
    get code_checkmark_hit_url(@code_checkmark_hit)
    assert_response :success
  end

  test "should get edit" do
    get edit_code_checkmark_hit_url(@code_checkmark_hit)
    assert_response :success
  end

  test "should update code_checkmark_hit" do
    patch code_checkmark_hit_url(@code_checkmark_hit), params: { code_checkmark_hit: { code_checkmark_id: @code_checkmark_hit.code_checkmark_id, hit_at: @code_checkmark_hit.hit_at } }
    assert_redirected_to code_checkmark_hit_url(@code_checkmark_hit)
  end

  test "should destroy code_checkmark_hit" do
    assert_difference('CodeCheckmarkHit.count', -1) do
      delete code_checkmark_hit_url(@code_checkmark_hit)
    end

    assert_redirected_to code_checkmark_hits_url
  end
end

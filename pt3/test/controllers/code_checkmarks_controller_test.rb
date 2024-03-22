require 'test_helper'

class CodeCheckmarksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @code_checkmark = code_checkmarks(:one)
  end

  test "should get index" do
    get code_checkmarks_url
    assert_response :success
  end

  test "should get new" do
    get new_code_checkmark_url
    assert_response :success
  end

  test "should create code_checkmark" do
    assert_difference('CodeCheckmark.count') do
      post code_checkmarks_url, params: { code_checkmark: { checkmark_id: @code_checkmark.checkmark_id, filename: @code_checkmark.filename, line_number: @code_checkmark.line_number, source_code_id: @code_checkmark.source_code_id } }
    end

    assert_redirected_to code_checkmark_url(CodeCheckmark.last)
  end

  test "should show code_checkmark" do
    get code_checkmark_url(@code_checkmark)
    assert_response :success
  end

  test "should get edit" do
    get edit_code_checkmark_url(@code_checkmark)
    assert_response :success
  end

  test "should update code_checkmark" do
    patch code_checkmark_url(@code_checkmark), params: { code_checkmark: { checkmark_id: @code_checkmark.checkmark_id, filename: @code_checkmark.filename, line_number: @code_checkmark.line_number, source_code_id: @code_checkmark.source_code_id } }
    assert_redirected_to code_checkmark_url(@code_checkmark)
  end

  test "should destroy code_checkmark" do
    assert_difference('CodeCheckmark.count', -1) do
      delete code_checkmark_url(@code_checkmark)
    end

    assert_redirected_to code_checkmarks_url
  end
end

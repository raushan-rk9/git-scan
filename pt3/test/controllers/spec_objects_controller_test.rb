require 'test_helper'

class SpecObjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @spec_object = spec_objects(:one)
  end

  test "should get index" do
    get spec_objects_url
    assert_response :success
  end

  test "should get new" do
    get new_spec_object_url
    assert_response :success
  end

  test "should create spec_object" do
    assert_difference('SpecObject.count') do
      post spec_objects_url, params: { spec_object: { data: @spec_object.data, type: @spec_object.type, value: @spec_object.value } }
    end

    assert_redirected_to spec_object_url(SpecObject.last)
  end

  test "should show spec_object" do
    get spec_object_url(@spec_object)
    assert_response :success
  end

  test "should get edit" do
    get edit_spec_object_url(@spec_object)
    assert_response :success
  end

  test "should update spec_object" do
    patch spec_object_url(@spec_object), params: { spec_object: { data: @spec_object.data, type: @spec_object.type, value: @spec_object.value } }
    assert_redirected_to spec_object_url(@spec_object)
  end

  test "should destroy spec_object" do
    assert_difference('SpecObject.count', -1) do
      delete spec_object_url(@spec_object)
    end

    assert_redirected_to spec_objects_url
  end
end

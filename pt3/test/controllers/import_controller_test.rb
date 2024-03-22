require 'test_helper'

class ImportControllerTest < ActionDispatch::IntegrationTest
  setup do
    user_pm
  end
  
  test "should get index" do
    get import_index_url
    assert_response :success
  end

end

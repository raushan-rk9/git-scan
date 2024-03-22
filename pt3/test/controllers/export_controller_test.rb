require 'test_helper'

class ExportControllerTest < ActionDispatch::IntegrationTest
  setup do
    user_pm
  end
  
  test "should get index" do
    get export_url
    assert_response :success
  end

end

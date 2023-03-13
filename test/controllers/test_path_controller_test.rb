require "test_helper"

class TestPathControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get test_path_index_url
    assert_response :success
  end
end

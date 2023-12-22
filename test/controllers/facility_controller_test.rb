require "test_helper"

class FacilityControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get facility_index_url
    assert_response :success
  end
end

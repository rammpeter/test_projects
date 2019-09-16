require 'test_helper'

class OracleTestControllerTest < ActionDispatch::IntegrationTest
  test "should get bind" do
    get oracle_test_bind_url
    assert_response :success
  end

end

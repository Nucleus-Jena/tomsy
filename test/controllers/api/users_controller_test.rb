require "test_helper"

class Api::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.find_by!(email: "srs_user@example.org")
    login_as @user
  end

  test "should get index of users" do
    get api_users_path(format: :json)
    assert_response :success
  end

  test "should get index of users for subset of users" do
    get api_users_path(max_result_count: 2, except: [@user.id], query: "admin", format: :json)
    assert_response :success
  end

  test "should get users" do
    get api_user_path(User.first, format: :json)
    assert_response :success
  end

  test "should get user info" do
    get info_api_user_path(id: "id param is ignored - results are for current user", format: :json)
    assert_response :success
  end
end

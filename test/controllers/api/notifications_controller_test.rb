require "test_helper"

class Api::NotificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.find_by!(email: "srs_user@example.org")
    login_as @user
  end

  test "should get index for marked notifications" do
    get api_notifications_path(marked: "1", format: :json)
    assert_response :success
  end

  test "should get index for unmarked notifications" do
    get api_notifications_path(marked: "0", format: :json)
    assert_response :success
  end

  test "should patch unread notification as marked" do
    notification = @user.notifications.unmarked.first

    patch mark_api_notification_path(notification, format: :json)
    assert_response :success
  end

  test "should respond with error when marking read notification" do
    notification = @user.notifications.marked.first

    patch mark_api_notification_path(notification, format: :json)
    assert_response :unprocessable_entity
  end

  test "should patch all unread notifications as marked" do
    patch mark_all_api_notifications_path(format: :json)
    assert_response :success
  end
end

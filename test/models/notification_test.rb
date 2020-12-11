require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @user = User.find_by!(email: "admin@example.org")
  end

  test "The user who triggered the event should not be notified" do
    notifiable_events = Event.where.not(subject: nil).select { |e| e.respond_to?(:notification_receivers) }
    assert_not_empty notifiable_events

    notifiable_events.each do |event|
      assert_not_includes event.notification_receivers, event.subject
    end
  end
end

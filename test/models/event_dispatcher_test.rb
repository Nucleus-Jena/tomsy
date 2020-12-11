require "test_helper"

class EventDispatcherTest < ActiveSupport::TestCase
  setup do
    @user = User.find_by!(email: "admin@example.org")
    @task = Workflow::Task.first
  end

  test "Creating an event triggers the creation of notifications for all receivers of this event" do
    @srs_user = User.find_by!(email: "srs_user@example.org")

    @task.update!(assignee: @user)
    @task.contributors = [@user, @srs_user]

    event = Events::TaskChangedDueDateEvent.new(subject: @user, object: @task, data: {new_due_date: Date.today})

    assert_not_empty event.notification_receivers

    assert_difference -> { Notification.count }, event.notification_receivers.count do
      event.save
    end
  end
end

require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @user = User.find_by!(email: "admin@example.org")
    @task = Workflow::Task.first
  end

  test "Event is not destroyed with user" do
    @user.events.destroy_all
    assert @user.events.none?

    event = Events::TaskChangedDueDateEvent.create!(subject: @user, object: @task, data: {new_due_date: Date.today})

    assert_equal 1, @user.reload.events.count

    @user.destroy
    assert_nil event.reload.subject
  end

  test "valid task changed due date event" do
    event = Events::TaskChangedDueDateEvent.new(subject: @user, object: @task, data: {new_due_date: Date.today})
    assert event.valid?
  end
end

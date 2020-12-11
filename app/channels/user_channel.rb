class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.broadcast_info(user)
    UserChannel.broadcast_to(user, task_info_json(user))
  end

  def self.task_info_json(user)
    Jbuilder.new { |json|
      ApplicationController.render(
        "api/users/info.json.jbuilder",
        assigns: {
          count_new_notifications: Notification.where(user: user, marked_at: nil).count,
          count_open_user_assigned_tasks: Workflow::Task.open.assigned_to(user).count,
          has_due_open_user_assigned_tasks: Workflow::Task.open.assigned_to(user).with_due_in_past.exists?
        },
        locals: {json: json}
      )
    }.attributes!
  end
  private_class_method :task_info_json
end

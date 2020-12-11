class Api::NotificationsController < ApiController
  def index
    marked = params[:marked]&.to_i == 1
    load_notifications_and_counts(marked, 20)
  end

  def mark_all
    Notification.where(user: current_user).unmarked.update_all(marked_at: Time.now)

    load_notifications_and_counts(false, 20)
    render :index
  end

  def mark
    notification = Notification.find_by(user: current_user, id: params[:id], marked_at: nil)
    if notification&.update(marked_at: Time.now)
      load_notifications_and_counts(false, 20)
      render :index
    else
      render json: notification&.errors&.messages, status: :unprocessable_entity
    end
  end

  private

  def load_notifications_and_counts(marked, count)
    @notifications = Notification.where(user: current_user)
    @notifications = marked ? @notifications.marked : @notifications.unmarked
    @notifications = @notifications.order(created_at: :desc).first(count)

    @counts = {
      marked: Notification.where(user: current_user).marked.count,
      unmarked: Notification.where(user: current_user).unmarked.count
    }
  end
end

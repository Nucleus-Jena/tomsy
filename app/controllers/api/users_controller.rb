class Api::UsersController < ApiController
  def index
    list

    render :list
  end

  def list
    excluded_user_ids = params[:except].to_a

    @users = User.all
    @users = @users.where.not(id: excluded_user_ids) unless excluded_user_ids.empty?

    if params[:query].present?
      query_str = "%#{params[:query]}%"
      @users = @users.where("concat_ws(' ', id, firstname, lastname, email) ILIKE ?", query_str)
    end

    @users = @users.order_by_name_with_user_first(current_user).first(10)
  end

  def show
    @user = User.find(params[:id])
  end

  def info
    @count_new_notifications = Notification.where(user: current_user, marked_at: nil).count
    @count_open_user_assigned_tasks = Workflow::Task.open.assigned_to(current_user).count
    @has_due_open_user_assigned_tasks = Workflow::Task.open.assigned_to(current_user).with_due_in_past.exists?
  end
end

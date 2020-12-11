require "test_helper"

class Interactors::TaskInteractorTest < ActiveSupport::TestCase
  def setup
    @user = User.find_by!(email: "admin@example.org")
    @process_definition = Workflow::ProcessDefinition.first

    # we need to create a test process to have a valid instance in camunda
    @running_process, = Workflow::Process.create_from_definition(@process_definition)
    @started_task = @running_process.tasks.started.first
  end

  test "#update_assignee with a user value should set the assignee of the task, add contributor if necessary and create an event" do
    assert_difference -> { Events::TaskAssignedEvent.count } do
      Interactors::TaskInteractor.update_assignee(@started_task, @user, @user)
    end

    assert_equal @user, @started_task.assignee
    assert @started_task.contributors.include?(@user)
  end

  test "#update_assignee with a nil value should clear the assignee of the task, add contributor if necessary and create an event" do
    @started_task.update!(assignee: @user)

    assert_difference -> { Events::TaskUnassignedEvent.count } do
      Interactors::TaskInteractor.update_assignee(@started_task, nil, @user)
    end

    assert_nil @started_task.assignee
    assert @started_task.contributors.include?(@user)
  end

  test "#update_contributors should add and remove users as contributors of the task if necessary and create an event" do
    removed_contributor = User.find_by!(email: "srs_user@example.org")
    @started_task.contributors << removed_contributor

    assert_difference -> { Events::TaskAddedContributorEvent.count } do
      assert_difference -> { Events::TaskRemovedContributorEvent.count } do
        Interactors::TaskInteractor.update_contributors(@started_task, User.where(id: @user.id), @user)
      end
    end

    assert @started_task.contributors.include?(@user)
    assert_not @started_task.contributors.include?(removed_contributor)
  end

  test "#update_due_at should change the due_at attribute of the task, add contributor if necessary and create an event" do
    new_due_date = Date.today

    assert_difference -> { Events::TaskChangedDueDateEvent.count } do
      Interactors::TaskInteractor.update_due_at(@started_task, new_due_date.to_s, @user)
    end

    assert_equal new_due_date, @started_task.due_at
    assert @started_task.contributors.include?(@user)
  end

  test "#complete should complete the task and create an event" do
    assert_difference -> { Events::TaskCompletedEvent.count } do
      Interactors::TaskInteractor.complete(@started_task, @user)
    end

    assert @started_task.reload.completed?
  end

  test "#mark should mark my task" do
    Interactors::TaskInteractor.update_marked(@started_task, true, @user)
    assert @started_task.reload.marked?(@user)
    assert_nothing_raised do
      Interactors::TaskInteractor.update_marked(@started_task, true, @user)
    end
    Interactors::TaskInteractor.update_marked(@started_task, false, @user)
    refute @started_task.reload.marked?(@user)
  end

  test "#update the description of the task with mentioning a user should work" do
    other_user = User.find_by!(email: "srs_user@example.org")

    params = ActionController::Parameters.new({
      task: {
        description: "<p>Changed Description <mention m-id=\"#{other_user.id}\" m-type=\"user\"></mention></p>"
      }
    })

    assert_difference -> { Events::TaskChangedSummaryEvent.count } do
      assert_difference -> { Notification.count } do
        Interactors::TaskInteractor.update(@started_task, params.require(:task).permit(:description), @user)
      end
    end

    assert_equal params[:task][:description], @started_task.description
    assert @started_task.contributors.include?(@user)
    assert Events::TaskChangedSummaryEvent.last.mentioned_users.include?(other_user)
  end

  test "#update_data should update the data_entity object of the task and if necessary add current_user as contributor" do
    new_working_title = "updated title"
    Interactors::TaskInteractor.update_data(@started_task, {working_title: new_working_title}, @user)

    assert_equal new_working_title, @started_task.process.data_entity.working_title
    assert @started_task.contributors.include?(@user)
  end
end

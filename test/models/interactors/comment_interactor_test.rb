require "test_helper"

class Interactors::CommentInteractorTest < ActiveSupport::TestCase
  def setup
    @current_user = User.find_by!(email: "admin@example.org")
    @any_task = Workflow::Task.first
  end

  test "#create should create comment and event and add to contributors if necessary" do
    @any_task.update!(contributors: [])

    assert_difference -> { Events::CommentCreatedEvent.count } do
      assert_difference -> { Comment.count } do
        Interactors::CommentInteractor.create("My own comment.", @any_task, @current_user)
      end
    end

    assert @any_task.contributors.include?(@current_user)
  end

  test "#create should add mentioned users if present" do
    any_user = User.first
    Interactors::CommentInteractor.create("mention a user <mention m-id=\"#{any_user.id}\" m-type=\"user\">#{any_user.mention_label}</mention>", @any_task, @current_user)
    created_event = Events::CommentCreatedEvent.last # TODO: We should refactor Event.create to return created object
    assert_equal [any_user], created_event.mentioned_users
  end

  test "it should be possible to create a comment for a process, task and ambition" do
    @task = Workflow::Task.first
    assert_difference -> { Events::CommentCreatedEvent.count } do
      assert_difference -> { @task.comments.count } do
        Interactors::CommentInteractor.create("My own comment.", @task, @current_user)
      end
    end

    @process = Workflow::Process.first
    assert_difference -> { Events::CommentCreatedEvent.count } do
      assert_difference -> { @process.comments.count } do
        Interactors::CommentInteractor.create("My own comment.", @process, @current_user)
      end
    end

    @ambition = Workflow::Task.first
    assert_difference -> { Events::CommentCreatedEvent.count } do
      assert_difference -> { @ambition.comments.count } do
        Interactors::CommentInteractor.create("My own comment.", @ambition, @current_user)
      end
    end
  end
end

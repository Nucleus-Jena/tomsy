require "test_helper"

class Interactors::ProcessInteractorTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @user = User.find_by!(email: "admin@example.org")
    @process_definition = Workflow::ProcessDefinition.first

    # we need to create a test process to have a valid instance in camunda
    @running_process, = Workflow::Process.create_from_definition(@process_definition)
  end

  test "#create should create process instance with assignee, contributor and ambition, create events and reindex all tasks" do
    ambition = Ambition.where(closed: false).first
    process = nil

    assert_difference -> { Events::TaskCreatedEvent.count }, @process_definition.task_definitions.count do
      assert_difference -> { Events::ProcessStartedEvent.count } do
        assert_difference -> { Workflow::Process.count } do
          assert_enqueued_with(job: Searchkick::ReindexV2Job) do
            process = Interactors::ProcessInteractor.create(@process_definition, ambition, nil, @user)
          end
        end
      end
    end

    assert_equal @user, process.assignee
    assert process.contributors.include?(@user)
    assert process.ambitions.include?(ambition)
  end

  test "#create with predecessor_process should create new process and set predecessor_process and create events" do
    predecessor_process = Workflow::Process.first
    process = nil

    assert_difference -> { Events::TaskCreatedEvent.count }, @process_definition.task_definitions.count do
      assert_difference -> { Events::ProcessStartedEvent.count } do
        assert_difference -> { Events::ProcessAddedSuccessorProcessEvent.count } do
          process = Interactors::ProcessInteractor.create(@process_definition, nil, predecessor_process, @user)
        end
      end
    end

    assert_equal predecessor_process, process.predecessor_process
    assert predecessor_process.successor_processes.include?(process)
  end

  test "#cancel should cancel process, add contributor if necessary, create an events and reindex all tasks" do
    started_tasks_count = @running_process.tasks.started.count

    assert_difference -> { Events::ProcessCanceledEvent.count } do
      assert_difference -> { Events::TaskCanceledEvent.count }, started_tasks_count do
        assert_enqueued_with(job: Searchkick::ReindexV2Job) do
          Interactors::ProcessInteractor.cancel(@running_process, "test canceling", @user)
        end
      end
    end

    assert @running_process.canceled?
    assert @running_process.contributors.include?(@user)
  end

  test "#update_assignee with a user value should set the assignee of the process, add contributor if necessary, create an event and reindex all tasks" do
    # assign
    assert_difference -> { Events::ProcessAssignedEvent.count } do
      assert_enqueued_with(job: Searchkick::ReindexV2Job) do
        Interactors::ProcessInteractor.update_assignee(@running_process, @user, @user)
      end
    end

    assert_equal @user, @running_process.assignee
    assert @running_process.contributors.include?(@user)
  end

  test "#update_assignee with a nil value should remove the assignee of the process, add contributor if necessary, create an event and reindex all tasks" do
    @running_process.update!(assignee: @user)

    assert_difference -> { Events::ProcessUnassignedEvent.count } do
      assert_enqueued_with(job: Searchkick::ReindexV2Job) do
        Interactors::ProcessInteractor.update_assignee(@running_process, nil, @user)
      end
    end

    assert_nil @running_process.assignee
    assert @running_process.contributors.include?(@user)
  end

  test "#update_contributors should add and remove users as contributors of the process and if necessary, create an event and reindex all tasks" do
    removed_contributor = User.find_by!(email: "srs_user@example.org")
    @running_process.contributors << removed_contributor

    assert_difference -> { Events::ProcessAddedContributorEvent.count } do
      assert_difference -> { Events::ProcessRemovedContributorEvent.count } do
        assert_enqueued_with(job: Searchkick::ReindexV2Job) do
          Interactors::ProcessInteractor.update_contributors(@running_process, User.where(id: @user.id), @user)
        end
      end
    end

    assert @running_process.contributors.include?(@user)
    assert_not @running_process.contributors.include?(removed_contributor)
  end

  test "#update should change the title of the process, add contributor if necessary, create an event and reindex all tasks" do
    update_params = {title: "test title"}

    assert_difference -> { Events::ProcessChangedTitleEvent.count } do
      assert_enqueued_with(job: Searchkick::ReindexV2Job) do
        Interactors::ProcessInteractor.update(@running_process, update_params, @user)
      end
    end

    assert_equal update_params[:title], @running_process.title
    assert @running_process.contributors.include?(@user)
  end

  test "#update the description of the process with a mentioning of a user should work" do
    other_user = User.find_by!(email: "srs_user@example.org")

    params = ActionController::Parameters.new({
      process: {
        description: "<p>Changed Description <mention m-id=\"#{other_user.id}\" m-type=\"user\"></mention></p>"
      }
    })

    assert_difference -> { Events::ProcessChangedSummaryEvent.count } do
      assert_difference -> { Notification.count } do
        Interactors::ProcessInteractor.update(@running_process, params.require(:process).permit(:description), @user)
      end
    end

    assert_equal params[:process][:description], @running_process.description
    assert @running_process.contributors.include?(@user)
    assert Events::ProcessChangedSummaryEvent.last.mentioned_users.include?(other_user)
  end

  test "#update_private_status should change the private attribute of the process, add contributor if necessary, create an event and reindex all tasks" do
    assert_changes -> { @running_process.private? } do
      assert_difference -> { Events::ProcessChangedVisibilityEvent.count } do
        assert_enqueued_with(job: Searchkick::ReindexV2Job) do
          Interactors::ProcessInteractor.update_private_status(@running_process, !@running_process.private?, @user)
        end
      end
    end

    assert @running_process.contributors.include?(@user)

    @running_process.contributors.delete(@user)
    assert_changes -> { @running_process.private? } do
      assert_difference -> { Events::ProcessChangedVisibilityEvent.count } do
        assert_enqueued_with(job: Searchkick::ReindexV2Job) do
          Interactors::ProcessInteractor.update_private_status(@running_process, !@running_process.private?, @user)
        end
      end
    end

    assert @running_process.contributors.include?(@user)
  end
end

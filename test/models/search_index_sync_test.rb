require "test_helper"

class SearchIndexSyncTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @user = User.find_by!(email: "srs_user@example.org")
    @a_new_process, = Workflow::Process.create_from_definition(Workflow::ProcessDefinition.find_by!(key: "patent_application"))
    @reindex_job_for_process = [job: Searchkick::ReindexV2Job, args: [@a_new_process.class.name, @a_new_process.id.to_s, nil, {routing: nil}]]
    @a_new_task = @a_new_process.tasks.started.first
    @reindex_job_for_processes_task = [job: Searchkick::ReindexV2Job, args: [@a_new_process.tasks.first.class.name, @a_new_task.id.to_s, nil, {routing: nil}]]
    @a_new_ambition = Ambition.create!(title: "Some new goal")
    @reindex_job_for_ambition = [job: Searchkick::ReindexV2Job, args: [@a_new_ambition.class.name, @a_new_ambition.id.to_s, nil, {routing: nil}]]
  end

  test "ambitions should be reindexed when visibility or search relevant changes occur" do
    assert_enqueued_with(*@reindex_job_for_ambition) { @a_new_ambition.update(assignee: @user) }
    assert_enqueued_with(*@reindex_job_for_ambition) { @a_new_ambition.contributors << @user }
    assert_enqueued_with(*@reindex_job_for_ambition) { @a_new_ambition.update(private: true) }
    assert_enqueued_with(*@reindex_job_for_ambition) { @a_new_ambition.update(deleted: true) }
    assert_enqueued_with(*@reindex_job_for_ambition) { @a_new_ambition.update(description: "Eine neue Beschreibung") }
    assert_enqueued_with(*@reindex_job_for_ambition) { Comment.create!(message: "a new comment", author: @user, object: @a_new_ambition) }

    # Processes should also be reindexed when Ambitions are marked as deleted
    @a_new_ambition.update(processes: [@a_new_process])
    assert_enqueued_with(*@reindex_job_for_process) { @a_new_ambition.update(deleted: true) }
  end

  test "ambitions.processes<< should trigger reindex" do
    assert_enqueued_with(*@reindex_job_for_ambition) do
      assert_enqueued_with(*@reindex_job_for_process) do
        @a_new_ambition.processes << @a_new_process
      end
    end
  end

  test "ambitions.processes= should trigger reindex" do
    assert_enqueued_with(*@reindex_job_for_ambition) do
      assert_enqueued_with(*@reindex_job_for_process) do
        @a_new_ambition.processes = [@a_new_process]
      end
    end
  end

  test "process should be reindexed when visibility or search  relevant changes occur" do
    assert_enqueued_with(*@reindex_job_for_process) { @a_new_process.update(private: true) }
    assert_enqueued_with(*@reindex_job_for_process) { @a_new_process.update(title: "Another new title") }
    assert_enqueued_with(*@reindex_job_for_process) { @a_new_process.update(description: "Eine neue Beschreibung") }
    assert_enqueued_with(*@reindex_job_for_process) { Comment.create!(message: "a new comment", author: @user, object: @a_new_process) }

    assert_enqueued_with(*@reindex_job_for_process) do
      assert_enqueued_with(*@reindex_job_for_processes_task) do
        @a_new_process.update(assignee: @user)
      end
    end

    assert_enqueued_with(*@reindex_job_for_process) do
      assert_enqueued_with(*@reindex_job_for_processes_task) do
        @a_new_process.update(assignee: nil)
      end
    end

    # After adding a ambition the ambition should be reindexed to show it's new Process Definition in search
    assert_enqueued_with(*@reindex_job_for_ambition) { @a_new_process.ambitions = [@a_new_ambition] }
  end

  test "process << methods should trigger reindex" do
    # Contributor may have visibility to process and task -> ACL update
    assert_enqueued_with(*@reindex_job_for_process) do
      assert_enqueued_with(*@reindex_job_for_processes_task) do
        @a_new_process.contributors << @user
      end
    end

    # Ambition index contains process_definitions, maybe a new one was added
    # process contains list of ambitions as filter
    assert_enqueued_with(*@reindex_job_for_process) do
      assert_enqueued_with(*@reindex_job_for_ambition) do
        @a_new_process.ambitions << @a_new_ambition
      end
    end
  end

  test "process = methods should trigger reindex" do
    assert_enqueued_with(*@reindex_job_for_process) do
      assert_enqueued_with(*@reindex_job_for_processes_task) do
        @a_new_process.contributors = [@user]
      end
    end

    assert_enqueued_with(*@reindex_job_for_process) do
      assert_enqueued_with(*@reindex_job_for_ambition) do
        @a_new_process.ambitions = [@a_new_ambition]
      end
    end
  end

  test "processes are enqueued for reindex when their data entities change" do
    data_entity = @a_new_process.reload.data_entity
    data_entity.update(reference: "GENESE-0323")
    assert_enqueued_with(*@reindex_job_for_process)
  end

  test "tasks should be reindexed when visibility or search relevant changes occur" do
    assert_enqueued_with(*@reindex_job_for_processes_task) { @a_new_task.update(description: "Eine neue Beschreibung") }
    assert_enqueued_with(*@reindex_job_for_processes_task) { Comment.create!(message: "a new comment", author: @user, object: @a_new_task) }
    assert_enqueued_with(*@reindex_job_for_processes_task) { @a_new_task.marked_by_users << @user }
    assert_enqueued_with(*@reindex_job_for_processes_task) { @a_new_task.marked_by_users = [] }
  end

  test "tasks AND process should be reindexed when visibility relevant changes occur concerning both" do
    assert_enqueued_with(*@reindex_job_for_process) do # If a user is allowed to see a single task this affects process ACL
      assert_enqueued_with(*@reindex_job_for_processes_task) do
        @a_new_task.contributors << @user
      end
    end

    assert_enqueued_with(*@reindex_job_for_process) do # If a user is allowed to see a single task this affects process ACL
      assert_enqueued_with(*@reindex_job_for_processes_task) do
        @a_new_task.contributors = []
      end
    end

    assert_enqueued_with(*@reindex_job_for_process) do # If a user is allowed to see a single task this affects process ACL
      assert_enqueued_with(*@reindex_job_for_processes_task) do
        @a_new_task.update(assignee: @user)
      end
    end

    assert_enqueued_with(*@reindex_job_for_process) do # If a user is allowed to see a single task this affects process ACL
      assert_enqueued_with(*@reindex_job_for_processes_task) do
        @a_new_task.update(assignee: nil)
      end
    end
  end

  test "task AND process should be reindex on taks state change" do
    assert_enqueued_with(*@reindex_job_for_process) do # If a user is allowed to see a single task this affects process ACL
      assert_enqueued_with(*@reindex_job_for_processes_task) do
        @a_new_task.complete
      end
    end
  end
end

require "test_helper"

class Workflow::TaskTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = User.find_by!(email: "admin@example.org")

    Workflow::Task.reindex
    Workflow::Task.searchkick_index.refresh
  end

  test "User assigned task is not destroyed with user" do
    @user.assigned_tasks.clear
    assert @user.assigned_tasks.none?

    process, = Workflow::Process.create_from_definition(
      Workflow::ProcessDefinition.find_by!(key: "initial_meeting_invention")
    )
    process.ambitions << Ambition.create(title: "Blubb Ziel")
    assert process.tasks.any?
    task = process.tasks.first
    task.update(assignee: @user)

    assert_equal 1, @user.reload.assigned_tasks.count

    @user.destroy
    assert_nil task.reload.assignee
  end

  test "#marked_counts should work" do
    marked_count_query = Workflow::Task.marked_count_query(@user, {where: {tab_categories: "STARTED"}})
    Searchkick.multi_search([marked_count_query])

    assert_equal @user.marked_tasks.count, marked_count_query.total_count
  end

  test "#tab_categories should report correctly" do
    process, = Workflow::Process.create_from_definition(
      Workflow::ProcessDefinition.find_by!(key: "initial_meeting_invention")
    )
    assert process.valid?

    task = process.tasks.min_by(&:order)
    assert_equal ["STARTED", "MARKED", "ALL"], task.reload.tab_categories
    task.process.update(private: true)
    assert_equal ["STARTED", "MARKED", "PRIVATE", "ALL"], task.reload.tab_categories
    task.update(due_at: 3.days.ago)
    assert_equal ["STARTED", "MARKED", "DUE", "PRIVATE", "ALL"], task.reload.tab_categories
    task.update(state: "completed")
    assert_equal ["MARKED", "COMPLETED", "PRIVATE", "ALL"], task.reload.tab_categories
  end

  test "#tab_categories_counts should report correctly" do
    results = Workflow::Task.search_for_index(@user, "*", true)
    assert_equal [["STARTED", 10], ["MARKED", 82], ["COMPLETED", 15], ["DUE", 2], ["PRIVATE", 13], ["ALL", 82]],
      Workflow::Task.tab_categories_counts(results)
  end

  test "scopes should work" do
    assert_nothing_raised do
      Workflow::Task.created.first
      Workflow::Task.started.first
      Workflow::Task.completed.first
      Workflow::Task.deleted.first
      Workflow::Task.open.first
      Workflow::Task.closed.first
      Workflow::Task.assigned_to(User.first).first
      Workflow::Task.open.with_due_in_past.first
    end
  end

  test "tasks should be found by their identifier and parts of title / subtitel" do
    task = Workflow::Task.find(47) # Beschreibung erstellen - Patentanmeldung > PA-1
    queries = ["#47", "47"]
    queries.each do |query|
      assert_equal task, Workflow::Task.search_for_list(@user, query).first, "Search by Workflow::Task.search_for_list for '#{query}' did not find correct result"
    end
    assert Workflow::Task.search_for_list(@user, "Patentanmeldung PA-1").include?(task)
  end
end

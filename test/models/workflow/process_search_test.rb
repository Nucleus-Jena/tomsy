require "test_helper"

class Workflow::ProcessSearchTest < ActiveSupport::TestCase
  setup do
    Workflow::Process.reindex
    Workflow::Process.searchkick_index.refresh
    @user = User.find_by_email!("admin@example.org")
    @process = Workflow::Process.first
  end

  test "#search_for_index should work" do
    results = Workflow::Process.search_for_index(@user)
    assert_not_empty results
  end

  test "#tab_categories should report correctly" do
    process = Workflow::Process.first
    assert_equal ["RUNNING", "WITH_DUE_TASKS", "ALL"], process.tab_categories
    process.update(private: true)
    assert_equal ["RUNNING", "WITH_DUE_TASKS", "PRIVATE", "ALL"], process.tab_categories
    process.tasks.each { |t| t.update(state: "completed") }
    assert_equal ["RUNNING", "PRIVATE", "ALL"], process.reload.tab_categories
    process.update(state: "completed")
    assert_equal ["COMPLETED", "PRIVATE", "ALL"], process.tab_categories
  end

  test "#tab_categories_counts should report correctly" do
    results = Workflow::Process.search_for_index(@user, "*", true)
    assert_equal [["RUNNING", 6], ["WITH_DUE_TASKS", 2], ["COMPLETED", 1], ["PRIVATE", 1], ["ALL", 9]],
      Workflow::Process.tab_categories_counts(results)
  end

  test "#search_for_index with aggregates and additional_query_params should work" do
    additional_params = {
      where: {
        tab_categories: "ALL"
      },
      order: {created_at: :desc}
    }
    result = Workflow::Process.search_for_index(@user, @process.title, true, additional_params)

    assert_equal [@process], result.to_a
  end

  test "processes should be found by their identifier and parts of title" do
    process = Workflow::Process.find(13) # srs-process
    queries = ["%13", "13", "srs"]
    queries.each do |query|
      assert_equal process, Workflow::Process.search_for_list(@user, query).first, "Search by Workflow::Process.search_for_list for '#{query}' did not find correct result"
    end
    assert Workflow::Process.search_for_list(@user, "Patentanmeldung").include?(process)
  end
end

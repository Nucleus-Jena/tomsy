require "test_helper"

class AmbitionSearchTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    # @ambition = Ambition.create(title: "A brand new Ziel")
    @ambition = @ambition_1 = Ambition.find(1) # Algenmarmelade
    @ambition_2 = Ambition.find(2) # Blockchain basierte Nutella
    @ambition_3 = Ambition.find(3) # Calamondinorangenbonbons
    @user = User.find_by!(email: "admin@example.org")

    Ambition.reindex
    Ambition.searchkick_index.refresh
  end

  test "ambition search_for_index should work" do
    results = Ambition.search_for_index(@user)
    assert_not_empty results
  end

  test "deleted ambitions should not be included in search" do
    perform_enqueued_jobs do
      @ambition.update!(deleted: true)
      Ambition.searchkick_index.refresh
    end
    assert_empty Ambition.search_for_index(@user, @ambition.title).to_a
  end

  test "ambition search_for_index should respect order" do
    perform_enqueued_jobs do
      @ambition_2.update!(title: "z Title", created_at: 200.years.from_now)
      @ambition_1.update!(title: "!A a Title", created_at: 200.years.ago)
      Ambition.searchkick_index.refresh
    end
    results = Ambition.search_for_index(@user, "*", false) # default ordered by name (=title)
    assert_equal @ambition_1, results.to_a.first
    assert_equal @ambition_2, results.to_a.last

    results = Ambition.search_for_index(@user, "*", false, order: {created_at: :desc})
    assert_equal @ambition_2, results.to_a.first
    assert_equal @ambition_1, results.to_a.last
  end

  test "ambition tab_categories should report correctly" do
    ambition = Ambition.first
    assert_equal ["OPEN", "ALL"], ambition.tab_categories
    ambition.processes.update_all(state: "running")
    assert_equal ["OPEN", "SOME_PROCESSES_RUNNING", "ALL"], ambition.reload.tab_categories
    ambition.update!(closed: true)
    assert_equal ["CLOSED", "ALL"], ambition.tab_categories
  end

  test "ambition#tab_categories_counts should report correctly" do
    results = Ambition.search_for_index(@user, "*", true)
    assert_equal [["OPEN", 8], ["SOME_PROCESSES_RUNNING", 2], ["CLOSED", 1], ["PRIVATE", 1], ["ALL", 9]],
      Ambition.tab_categories_counts(results)
  end

  test "search_for_index with additional_query_params should still respect privacy" do
    srs_user = User.find_by!(email: "srs_user@example.org")
    assert_equal @ambition, Ambition.search_for_index(srs_user, @ambition.title, true, {where: {_and: []}}).first
    perform_enqueued_jobs do
      @ambition.update!(private: true)
      Ambition.searchkick_index.refresh
    end

    assert_empty Ambition.search_for_index(srs_user, @ambition.title, true, {where: {_and: []}}).to_a
  end

  test "search_for_index should return right ambitions for filter" do
    assert_equal @ambition_1, Ambition.search_for_index(@user, "Algenmarmelade").first
    # TODO: Extend filtering tests. Issue: #478
  end

  test "ambitions should be found by their identifier and parts of title" do
    ambition = Ambition.find(2) # Blockchain basierte Nutella
    queries = ["!2", "2", "chain", "tell"]
    queries.each do |query|
      assert_equal ambition, Ambition.search_for_list(@user, query).first, "Seach by Ambition.search_for_list for '#{query}' did not find ambition as first result"
    end
  end
end

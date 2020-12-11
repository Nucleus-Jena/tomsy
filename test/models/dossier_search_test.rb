require "test_helper"

class DossierSearchTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @dossier = Dossier.find(1) # Admin User
    @dossier_2 = Dossier.find(2) # Some Other User
    @user = User.find_by!(email: "admin@example.org")

    Dossier.reindex
    Dossier.searchkick_index.refresh
  end

  test "dossier search_for_index should work" do
    results = Dossier.search_for_index(@user)
    assert_not_empty results
  end

  test "dossier search_for_index should respect order" do
    perform_enqueued_jobs do
      @dossier_2.update!(created_at: 200.years.from_now)
      @dossier.update!(created_at: 200.years.ago)
      Dossier.searchkick_index.refresh
    end

    results = Dossier.search_for_index(@user, "*", false, order: {created_at: :desc})
    assert_equal @dossier_2, results.to_a.first
    assert_equal @dossier, results.to_a.last
  end

  test "deleted dossier should not be included in search" do
    perform_enqueued_jobs do
      @dossier.update!(deleted: true)
      Dossier.searchkick_index.refresh
    end
    assert_empty Dossier.search_for_index(@user, @dossier.title).to_a
  end

  test "searching for data fields should work" do
    results = Dossier.search("James")
    assert_equal @dossier_2, results.first
  end
end

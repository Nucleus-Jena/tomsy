require "test_helper"

class SearchTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    CustomElasticSearchConfig.initalize_searchkick_indexes
  end

  test "simple Process.search should work" do
    ambition = Ambition.first
    process_definition = Workflow::ProcessDefinition.find_by!(key: "patent_application")
    process, = Workflow::Process.create_from_definition(process_definition)
    process.ambitions << ambition

    Workflow::Process.searchkick_index.refresh # This triggers ES to update index immediately and not after 1 second as otherwise

    assert process, Workflow::Process.search(ambition.title).first
  end

  test "Fulltext Search should work" do
    my_search = Search.new

    assert_not_empty my_search.fulltext
  end

  test "titles should be weighted higher than other attributes" do
    ambition = Ambition.find(2) # Blockchain basierte Nutella
    process = Workflow::Process.first
    perform_enqueued_jobs { Workflow::Process.first.ambitions << ambition }

    CustomElasticSearchConfig.sync_all_indexes

    results = Search.new.fulltext("Nutella", {per_page: 1000}).to_a

    assert results.include?(process) # because it's Ambition is Nutella
    assert_equal ambition, results.first
  end

  test "private ambitions should not cause processeses to be found - quickfix for #469" do
    ambition = Ambition.find(2) # Blockchain basierte Nutella
    process = Workflow::Process.find(11) # Patentanmeldung

    assert Search.new.fulltext("Blockchain Nutella").include?(process)

    perform_enqueued_jobs { ambition.update!(private: true) }
    CustomElasticSearchConfig.sync_all_indexes

    refute Search.new.fulltext("Blockchain Nutella").include?(process)
  end

  test "private processes should not be found if not visible" do
    private_process = Workflow::Process.find(17) # Geburtstagsparty
    srs_user = private_process.assignee
    assert Search.new(srs_user).fulltext("Geburtstag").include?(private_process)

    no_access_user = User.find_by(email: "no_access_user@example.org")
    refute Search.new(no_access_user).fulltext("Geburtstag").include?(private_process)
  end

  test "tasks, processes, ambitions should be found via their comments" do
    query = "suchTestKommentare"
    results = Search.new.fulltext(query)
    assert results.include?(Workflow::Task.find(59))
    assert results.include?(Workflow::Process.find(13))
    assert results.include?(Ambition.find(2))
  end

  test "tasks, processes, ambitions should be found by their identifier" do
    assert Search.new.fulltext("#59").first(5).include?(Workflow::Task.find(59))
    assert Search.new.fulltext("%13").first(5).include?(Workflow::Process.find(13))
    assert Search.new.fulltext("!2").first(5).include?(Ambition.find(2))
  end

  test "search should work with umlaute and other special chars" do
    a_ambition = Ambition.first

    perform_enqueued_jobs { a_ambition.update!(description: "Dies ist ein Text mit Umläuten und anschließend mit 😉.") }
    CustomElasticSearchConfig.sync_all_indexes

    assert_equal a_ambition, Search.new.fulltext("Umläuten").first
    assert_equal a_ambition, Search.new.fulltext("anschließend").first
    assert_equal a_ambition, Search.new.fulltext("😉").first
  end

  test "search should suggest better queries" do
    misspelled_query = "Freiher" # is stemmed to "freih" and thus even with misspellings search does not find "Freiherr"

    suggestions = Dossier.search(misspelled_query, suggest: true).suggestions
    assert_equal "freiherr", suggestions.first

    fulltext_suggestions = Search.new.fulltext(misspelled_query).suggestions
    assert_equal "freiherr", fulltext_suggestions.first
  end
end

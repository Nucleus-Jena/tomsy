require "application_system_test_case"
require "integration_test_helper"

class SearchSystemTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper
  setup do
    @user = User.find_by!(email: "srs_user@example.org")
    login_as(@user)
  end

  test "searching basically should work" do
    CustomElasticSearchConfig.initalize_searchkick_indexes

    visit root_url

    fill_in "fulltext-search", with: "Algenmarmelade\n"

    search_results = page.all("#search-results > div", text: "Algenmarmelade")

    search_result_ambition = search_results.first
    assert search_result_ambition.find(".v-list-item__title", text: "Algenmarmelade")

    search_result_process = search_results.last
    assert search_result_process.find(".search-result-highlights", text: /Algenmarmelade/)

    fill_in "fulltext-search", with: "Gespräch\n"
    assert_not_empty page.all("#search-results > div")

    fill_in "fulltext-search", with: "SRS\n"
    assert_not_empty page.all("#search-results > div")
  end

  test "after uploading a file it may be found in the search" do
    visit "/processes/11/task/54" # Task: Beschreibung erstellen

    click_on "Datei hinzufügen"
    fill_in "Titel", with: "Eine Test Datei"
    file_to_upload = File.join(Rails.root, "test/fixtures/files/cairo-multiline.pdf")
    page.driver.browser.all(:xpath, '//input[@type="file"]').first.send_keys(file_to_upload)
    perform_enqueued_jobs do # to immediately execute reindex jobs from document
      click_on "Speichern"
    end

    Workflow::Process.searchkick_index.refresh
    fill_in "fulltext-search", with: "From James\n"

    search_results = page.all("#search-results > div")
    assert_not_empty search_results
    assert search_results.find(text: "Hello World From James")

    visit "/processes/13/task/68" # Task: Beschreibung erstellen from differen Process
    click_on "Link hinzufügen"
    fill_in "Titel", with: "Ein Test Link"
    fill_in "Url", with: "http://james-der-test.example.org/home.html"
    perform_enqueued_jobs do # to immediately execute reindex jobs from document
      click_on "Speichern"
    end
    Workflow::Process.searchkick_index.refresh
    fill_in "fulltext-search", with: "http://james-der-test.example.org/home.html\n"
    search_results = page.all("#search-results > div")
    assert_not_empty search_results
  end
end

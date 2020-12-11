require "application_system_test_case"
require "integration_test_helper"
require "system_test_helper"

class ProcessesTest < ApplicationSystemTestCase
  setup do
    @user = User.find_by!(email: "srs_user@example.org")
    login_as(@user)

    @process = Workflow::Process.first
  end

  test "creating a process and closing a task should work" do
    process_definition = Workflow::ProcessDefinition.first
    visit root_url
    page.find(".v-toolbar").click_on "Maßnahmen"

    click_on "Maßnahme starten"
    click_menu_list_item process_definition.name
    click_menu_card_action_button "STARTEN"

    assert_css ".page-process"
    assert_css ".v-breadcrumbs", text: process_definition.name
    assert_css ".page-detail-header .v-chip__content", text: "Gestartet"

    # complete task
    click_on "Art der Veranstaltung angeben"
    assert_css ".page-detail-header .v-chip__content", text: "Gestartet"
    click_on "Aufgabe abschließen"
    assert_css ".page-detail-header .v-chip__content", text: "Abgeschlossen"
  end

  test "updating and commenting of a processs should work and create a notification for the mentioned user" do
    visit root_url
    page.find(".v-toolbar").click_on "Maßnahmen"

    click_on @process.title

    # Edit title and description
    new_title = "New process test title"
    new_description = "New process test description"
    open_title_and_description_card
    fill_in_title_and_description new_title, new_description
    click_title_and_description_edit_button "SPEICHERN"
    assert_text new_title
    assert_text new_description

    # Comment and mention a user.
    @process.reload
    mention_user = User.find_by!(email: "admin@example.org")
    new_comment = "Ein kleiner Kommentar. Benachrichtigen möchte ich "

    activity_hub_element = page.find(".activity-hub")
    editor = find_prosemirror_editor(activity_hub_element)

    prosemirror_fill_in(editor, new_comment + "@")
    page.find(".mention-suggestions-menu .v-list-item", text: mention_user.email).click
    activity_hub_element.click_button("Kommentieren")
    activity_hub_element.find(".v-timeline-item").assert_text new_comment + mention_user.mention_label

    # Mentioned user should have received his notification
    logout_using_menu
    login_as(mention_user)
    visit root_url
    page.find("#user-notifications-button").click
    item = page.find(".v-timeline-item.comment-item", text: new_comment + mention_user.mention_label)
    item.assert_text "#{@user.name} hat Dich in einem Kommentar zu Maßnahme %#{@process.id} • #{@process.title} erwähnt"
  end
end

require "application_system_test_case"
require "integration_test_helper"
require "system_test_helper"

class AmbitionSystemTest < ApplicationSystemTestCase
  setup do
    @user = User.find_by!(email: "srs_user@example.org")
    login_as @user
    @ambition = Ambition.first
  end

  test "creating an ambition should work" do
    visit root_url

    click_button "Ziel erstellen"
    fill_in "Titel des neuen Ziels", with: "Test Ziel"
    click_menu_card_action_button "ERSTELLEN"

    assert_css ".page-ambition"
    assert_css ".v-breadcrumbs .v-breadcrumbs__item", text: "Ziele"
    assert_css ".page-detail-header .v-chip__content", text: "Eröffnet"
  end

  test "deleting an ambition should work" do
    visit root_url
    click_on @ambition.title

    open_vertical_dots_context_menu
    assert has_menu_list_item("Ziel löschen", true)
    set_assignee @user

    open_vertical_dots_context_menu

    click_menu_list_item "Ziel löschen"

    click_dialog_button "LÖSCHEN"

    assert_current_path "/ambitions"
  end

  test "updating title and description of an ambition should work" do
    ambition_title = "ambition test title"
    ambition_description = "ambition test description"

    visit root_url
    click_on @ambition.title

    open_title_and_description_card
    fill_in_title_and_description ambition_title, ambition_description
    click_title_and_description_edit_button "SPEICHERN"

    assert_text ambition_title
    assert_text ambition_description
  end

  test "canceling the editing of title and description of an ambition should work" do
    @ambition.update!(title: "ambition test title", description: "ambition test description")
    visit root_url
    click_on @ambition.title

    assert_text @ambition.title
    assert_text @ambition.description

    open_title_and_description_card
    fill_in_title_and_description "#{@ambition.title}_changed", "#{@ambition.description}_changed"
    click_title_and_description_edit_button "ABBRECHEN"

    assert_text @ambition.title
    assert_text @ambition.description
  end

  test "adding/removing an existing process to/from an ambition should work" do
    @ambition.processes.delete_all
    process = Workflow::Process.first

    visit root_url
    click_on @ambition.title

    assert page.has_no_css?(".custom-object-control .v-card .v-list .v-list-item--link", text: process.title)

    click_ambition_process_select_button
    page.find(".custom-object-control .v-card .v-menu__content .v-list .v-list-item--link", text: process.title).click
    click_ambition_process_select_button

    assert page.has_css?(".custom-object-control .v-card .v-list .v-list-item--link", text: process.title)

    click_ambition_process_select_button
    page.find(".custom-object-control .v-card .v-menu__content .v-list .v-list-item--link", text: process.title).click
    click_ambition_process_select_button

    assert page.has_no_css?(".custom-object-control .v-card .v-list .v-list-item--link", text: process.title)
  end

  test "closing and reopening an ambition should work" do
    visit root_url
    click_on @ambition.title

    open_vertical_dots_context_menu
    assert has_menu_list_item("Ziel abschließen", true)
    set_assignee @user

    open_vertical_dots_context_menu
    click_menu_list_item "Ziel abschließen"
    click_dialog_button "ABSCHLIESSEN"

    open_vertical_dots_context_menu
    click_menu_list_item "Ziel wiedereröffnen"

    open_vertical_dots_context_menu
    assert has_menu_list_item("Ziel abschließen")
  end

  test "closed ambition should not allow to add or remove a process" do
    @ambition.update(closed: true)

    visit root_url
    click_on @ambition.title

    assert page.find(".custom-object-control .v-card .v-card__title div", text: "Zu erledigende Maßnahmen")
      .find(:xpath, "..")
      .has_css?("button:disabled", text: "ÄNDERN")
  end
end

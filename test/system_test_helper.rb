def set_assignee(user)
  within(control_for("Verantwortlicher")) { click_button("Ändern") }
  page.find(".v-menu__content .v-list .v-list-item--link", text: user.name).click
end

def control_for(text)
  page.find(".v-input.custom-object-control", text: text)
end

def right_sidebar
  page.find(".v-navigation-drawer--right")
end

def left_sidebar
  page.find(".v-navigation-drawer", match: :first)
end

def middle_area
  page.find(".container")
end

def find_text(text)
  find("*", text: text)
end

def open_vertical_dots_context_menu
  page.find("button .v-icon.mdi-dots-vertical").click
end

def open_title_and_description_card
  page.find("button .v-icon.mdi-square-edit-outline").click
end

def find_prosemirror_editor(parent)
  parent.find(".tiptap-vuetify-editor .ProseMirror")
end

def prosemirror_fill_in(element, text)
  element.base.send_keys(text)
end

def fill_in_title_and_description(title, description)
  unless title.nil?
    page.find(".v-card .v-input .v-text-field__slot .v-label", text: "Titel")
      .find(:xpath, "..")
      .find("input[type=text]")
      .fill_in with: title
  end

  unless description.nil?
    editor_parent = page.find(".v-card .editor-control__wrapper .v-label", text: "Beschreibung")
      .find(:xpath, "..")

    prosemirror_fill_in(find_prosemirror_editor(editor_parent), description)
  end
end

def click_title_and_description_edit_button(text)
  page.find(".v-card .v-card__actions button", text: text).click
end

def has_menu_list_item(text, disabled = false)
  page.has_css?(".v-menu__content .v-list #{disabled ? ".v-list-item--disabled" : ".v-list-item--link"}", text: text)
end

def click_menu_list_item(text)
  page.find(".v-menu__content .v-list .v-list-item--link", text: text).click
end

def click_dialog_button(text)
  page.find(".v-dialog button", text: text).click
end

def click_menu_card_action_button(text)
  page.find(".v-menu__content .v-card .v-card__actions button", text: text).click
end

def click_ambition_process_select_button
  page.find(".custom-object-control .v-card .v-card__title div", text: "Zu erledigende Maßnahmen")
    .find(:xpath, "..")
    .find("button", text: "ÄNDERN")
    .click
end

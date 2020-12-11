def login_using_form_with(email, password = "password")
  visit root_url
  assert has_text?("Anmelden")

  within("form#sign-in") do
    fill_in("user[email]", with: email)
    fill_in("user[password]", with: password)
    click_button("Anmelden")
  end
end

# #logout fails flakely on CI. To further pinpoint problem we start storing more screenshots if this fails.
def logout_using_menu
  screenshots_for_debugging = []
  find_button("user-menu").click
  assert has_text?("Abmelden")
  screenshots_for_debugging << page.save_screenshot(Rails.root.join("tmp/screenshots/after-opening-menu.png"))

  list_of_user_menu_items = find("#user-menu-list")
  logout_link = list_of_user_menu_items.find("a", text: "Abmelden")
  logout_link.click
  screenshots_for_debugging << page.save_screenshot(Rails.root.join("tmp/screenshots/after-clicking-lougout.png"))
  assert_current_path(new_user_session_path)
  assert has_text?("Anmelden")

  # cleanup if successfull
  screenshots_for_debugging.map { |screenshot_path| File.delete(screenshot_path) }
end

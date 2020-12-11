require "application_system_test_case"
require "integration_test_helper"
require "system_test_helper"

class UserAuthenticationTest < ApplicationSystemTestCase
  setup do
    logout
  end

  # Simulating timout of session is a bit harder than expected. We tried several other options before settling on
  # warden highjacking (is fastest and reliable)
  # Tried: Devise/Warden sign_out helpers, deleting cookies, mokey-patching timedout? method on user object,
  # changing devise config timout for this test and sleeping @user.timout_in
  test "a user who's session expires should be shown sign in form" do
    visit root_path
    assert_equal new_user_session_path, current_path

    login_using_form_with("srs_user@example.org")

    assert_button("user-menu") # We are logged in

    logout_user_by_setting_warden_env

    click_on "Aufgaben" # clicking anywhere should trigger app to realize our session has timed out
    assert has_text?("Anmelden") # we are shown login form
    assert_equal new_user_session_path, current_path
  end

  test "only user within admin group can visit admin interface" do
    login_using_form_with("srs_user@example.org")
    page.find_button("user-menu").click
    refute page.has_link?("Rails Admin")
    page.find_button("user-menu").click # close menu

    visit rails_admin.dashboard_path
    assert has_text? "Sie dürfen nicht auf diese Seite zugreifen."

    visit root_path
    logout_using_menu

    login_using_form_with("admin@example.org")

    page.find_button("user-menu").click
    rails_admin_tab = window_opened_by { click_link "Rails Admin" }
    within_window rails_admin_tab do
      assert has_text?("Administration")
      assert_equal rails_admin.dashboard_path, current_path
    end
  end

  private

  def logout_user_by_setting_warden_env
    Warden.on_next_request do |proxy|
      session = proxy.env["rack.session"]["warden.user.user.session"]
      session["last_request_at"] -= User.timeout_in
    end
  end
end

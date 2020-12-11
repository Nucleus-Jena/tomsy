require "test_helper"

class VueIntegrationTest < ActionDispatch::IntegrationTest
  test "vue should not be active without javascript (as is the case for integration tests" do
    visit root_path

    refute has_text?("with Vue.js")
  end
end

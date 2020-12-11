require "./test/simplecov_env"
SimpleCovEnv.start!

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"

require "capybara/rails"
require "capybara/minitest"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  setup do
    # Enforce loading all DataEntity types available in current Database. On CI tests are flaky if sublasses are not yet loaded.
    ProcessDataEntity.unload_subclasses
    ProcessDataEntity.eager_load_subclasses
  end
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests (visit _url_ etc.)
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # include Devise::Test::IntegrationHelpers # allows sign_in(@user) but we do not use it
  include Warden::Test::Helpers # allows login_as(@user)

  Warden.test_mode!

  teardown do
    Warden.test_reset!
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

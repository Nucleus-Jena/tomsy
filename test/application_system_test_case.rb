require "test_helper"
require "minitest/retry"

Minitest::Retry.use!
Minitest::Retry.on_retry do |klass, test_name, result|
  Raven.capture_message StandardError.new("FlakySystemTest #{klass} #{test_name}"),
    extra: {klass: klass, test_name: test_name, result: result}
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome,
                       screen_size: [1360, 1020], # Selenium defaults - we can chose whatever
                       options: {url: ENV["SELENIUM_URL"]} # If running on CI we use a remote instance

  Capybara.default_max_wait_time = 5.seconds.to_i
  Capybara.default_max_wait_time = 1.minute.to_i if ENV["CI"]

  include Warden::Test::Helpers # allows login_as(@user)

  Warden.test_mode!

  setup do
    # We must also tell SystemTest where to find rails server
    host! "http://#{Capybara.server_host}:#{Capybara.server_port}"

    CustomElasticSearchConfig.initalize_searchkick_indexes
  end

  teardown do
    Warden.test_reset!
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

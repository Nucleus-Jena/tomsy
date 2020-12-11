require "test_helper"

class Api::ProcessDefinitionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    CustomElasticSearchConfig.initalize_searchkick_indexes
    login_as User.first
  end

  test "should get index" do
    get api_process_definitions_url(format: :json)
    assert_response :success
  end
end

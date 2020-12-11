require "test_helper"

class Api::SearchControllerTest < ActionDispatch::IntegrationTest
  def setup
    CustomElasticSearchConfig.initalize_searchkick_indexes
    login_as User.first
  end

  test "should get index" do
    get api_search_fulltext_path(query: "james", format: :json)
    assert_response :success
  end

  test "should get index with pagination" do
    get api_search_fulltext_path(query: "*", page: 3, format: :json)
    assert_response :success
  end
end

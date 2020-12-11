require "test_helper"

class Api::DossierDefinitionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @current_user = User.find_by!(email: "srs_user@example.org")
    login_as @current_user
  end

  test "should get index" do
    get api_dossier_definitions_path(format: :json)
    assert_response :success
  end
end

require "test_helper"

class Api::DossiersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @current_user = User.find_by!(email: "srs_user@example.org")
    login_as @current_user
    @dossier_definition = DossierDefinition.find_by(identifier: "person")
    @dossier = @dossier_definition.dossiers.find(1) # Admin User
  end

  test "should refuse index to not logged in users" do
    logout
    get api_dossiers_path(format: :json)
    assert_response :unauthorized
  end

  test "should get index" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get api_dossiers_path(format: :json)
    assert_response :success
  end

  test "should get index with additional query params" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    params = {
      page: 1,
      query: "james",
      definitions: [@dossier_definition.identifier],
      field: "Name",
      field_query: @dossier.get_field_value("name")
    }
    get api_dossiers_path(format: :json), params: params
    assert_response :success
  end

  test "should get list with query params" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    params = {
      definition: @dossier_definition.identifier,
      except: [@dossier.id],
      query: "user"
    }
    get list_api_dossiers_path(format: :json), params: params
    assert_response :success
  end

  test "should get dossier show" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get api_dossier_path(@dossier, format: :json)
    assert_response :success
  end

  test "should refuse to get show of a deleted dossier" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    deleted_dossier = Dossier.find_by(deleted: true)
    get api_dossier_path(deleted_dossier, format: :json)
    assert_response :gone
  end

  test "should get new, a not persisted dossier" do
    get new_api_dossier_path(format: :json), params: {dossier_definition_id: @dossier_definition.id}
    assert_response :success
  end

  test "should create a new dossier" do
    assert_difference -> { Dossier.count } do
      post api_dossiers_path(format: :json), params: {
        dossier_definition_id: @dossier_definition.id,
        field_data: {email: "test@test.org", name: "Test Dossier Name"}
      }
    end
    assert_response :success
  end

  test "should not create a new dossier without all required fields" do
    assert_no_difference -> { Dossier.count } do
      post api_dossiers_path(format: :json), params: {
        dossier_definition_id: @dossier_definition.id,
        field_data: {email: "test@test.org"}
      }
    end
    assert_response :unprocessable_entity
  end

  test "should update dossier" do
    patch api_dossier_path(@dossier, format: :json), params: {identifier: "name", value: "Updated Name"}
    assert_response :success
  end

  test "should respond with error to invalid update" do
    patch api_dossier_path(@dossier, format: :json), params: {identifier: "name", value: nil}
    assert_response :unprocessable_entity
  end

  test "should delete dossier" do
    delete api_dossier_path(@dossier, format: :json)
    assert_response :success
  end

  test "should get dossier show_references" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get show_references_api_dossier_path(@dossier, format: :json)
    assert_response :success
  end

  test "should refuse to get show_references of a deleted dossier" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    deleted_dossier = Dossier.find_by(deleted: true)
    get show_references_api_dossier_path(deleted_dossier, format: :json)
    assert_response :gone
  end
end

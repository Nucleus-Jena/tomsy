require "test_helper"

class Api::AmbitionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @current_user = User.find_by!(email: "srs_user@example.org")
    login_as @current_user
    @ambition = Ambition.find(2) # Nutella
  end

  test "should get index" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get api_ambitions_path(format: :json)
    assert_response :success
  end

  test "should get index with additional query params" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    params = {
      page: 1,
      query: "james",
      assignee_ids: [@current_user.id],
      contributor_ids: [@current_user.id],
      process_definition_ids: [Workflow::ProcessDefinition.first.id],
      tab_category: "OPEN",
      order: "asc"
    }
    get api_ambitions_path(params.merge({format: :json}))
    assert_response :success
  end

  test "should get list" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get list_api_ambitions_path(format: :json)
    assert_response :success
  end

  test "should get list with additional query params" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get list_api_ambitions_path(query: "james", except: [Ambition.first.id], format: :json)
    assert_response :success
  end

  test "should get ambition show" do
    get api_ambition_path(@ambition, format: :json)
    assert_response :success
  end

  test "should get deleted ambition show" do
    @ambition.update!(deleted: true)
    get api_ambition_path(@ambition, format: :json)
    assert_response :gone
  end

  test "should get activities" do
    get activities_api_ambition_path(@ambition, format: :json)
    assert_response :success
  end

  test "should update ambitions" do
    patch api_ambition_path(@ambition, format: :json), params: {ambition: {title: "More Nutella for all!"}}
    assert_response :success
  end

  test "should respond with error to invalid update" do
    patch api_ambition_path(@ambition, format: :json), params: {ambition: {title: ""}}
    assert_response :unprocessable_entity
  end

  test "should update private status" do
    @ambition.update(assignee: @current_user)
    patch update_private_status_api_ambition_path(@ambition, format: :json), params: {private: !@ambition.private}
    assert_response :success
  end

  test "should update_assignee" do
    patch update_assignee_api_ambition_path(@ambition, format: :json), params: {assignee: @current_user.id}
    assert_response :success
  end

  test "should allow removing assignee" do
    patch update_assignee_api_ambition_path(@ambition, format: :json), params: {assignee: nil}
    assert_response :success
  end

  test "should update_contributors" do
    @ambition.update(assignee: @current_user)
    patch update_contributors_api_ambition_path(@ambition, format: :json), params: {contributors: User.all.limit(3).pluck(:id)}
    assert_response :success
  end

  test "should allow removing all contributors" do
    @ambition.update(assignee: @current_user)
    patch update_contributors_api_ambition_path(id: @ambition.id, format: :json), params: {contributors: [nil]}
    assert_response :success
  end

  test "should update_processes" do
    patch update_processes_api_ambition_path(@ambition, format: :json), params: {processes: Workflow::Process.all.limit(3).pluck(:id)}
    assert_response :success
  end

  test "should allow removing all processes" do
    patch update_processes_api_ambition_path(@ambition, format: :json), params: {processes: [nil]}
    assert_response :success
  end

  test "should create a new ambition" do
    assert_difference -> { Ambition.count } do
      post api_ambitions_path(format: :json), params: {ambition: {title: "My brand new ambition"}}
    end
    assert_response :success
  end

  test "should not create a new ambition with empty title" do
    assert_no_difference -> { Ambition.count } do
      post api_ambitions_path(format: :json), params: {ambition: {title: ""}}
    end
    assert_response :unprocessable_entity
  end

  test "should close ambition" do
    @ambition.update!(assignee: @current_user)

    patch close_api_ambition_path(@ambition, format: :json)
    assert_response :success
  end

  test "should reopen closed ambition" do
    @ambition.update!(assignee: @current_user)
    @ambition.update(closed: true)

    patch reopen_api_ambition_path(@ambition, format: :json)
    assert_response :success
  end

  test "should delete ambition" do
    @ambition.update!(assignee: @current_user)
    delete api_ambition_path(@ambition, format: :json)
    assert_response :success
  end

  test "should add comments to ambition" do
    assert_difference -> { Comment.count } do
      post comment_api_ambition_path(@ambition, format: :json), params: {message: "Ein neuer Kommentar"}
    end
    assert_response :success
  end

  test "update requires 'processes' params to be set" do
    assert_raises ActionController::ParameterMissing do
      patch update_processes_api_ambition_path(@ambition, format: :json), params: {wrong_proccesses_param: []}
    end
  end
end

require "test_helper"

class Api::ProcessesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @current_user = User.find_by!(email: "srs_user@example.org")
    @no_access_user = User.find_by!(email: "no_access_user@example.org")

    @srs_process = Workflow::Process.find_by!(title: "srs-process")

    login_as(@current_user)
  end

  test "index should work" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get api_processes_url(format: :json)
    assert_response :success
  end

  test "index should work when filtering" do
    CustomElasticSearchConfig.initalize_searchkick_indexes

    params = {
      page: 1,
      query: "james",
      assignee_ids: [@current_user.id],
      contributor_ids: User.all.limit(3).pluck(:id),
      process_definition_ids: [Workflow::ProcessDefinition.first.id],
      ambition_ids: Ambition.all.limit(5).pluck(:id),
      tab_category: "RUNNING",
      order: "desc"
    }

    get api_processes_url(params.merge(format: :json))
    assert_response :success
  end

  test "should get list" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get list_api_processes_path(format: :json)
    assert_response :success
  end

  test "should get list with filtering" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    params = {
      query: "james",
      except: Workflow::Process.all.limit(3).pluck(:id),
      max_result_count: 2
    }
    get list_api_processes_path(params.merge(format: :json))
    assert_response :success
  end

  test "process#show should work" do
    get api_process_url(@srs_process, format: :json)
    assert_response :success
  end

  test "should get process activities" do
    get activities_api_process_path(@srs_process, format: :json)
    assert_response :success
  end

  test "should update process" do
    patch api_process_path(@srs_process, format: :json), params: {process: {title: "Ein neuer Titel"}}
    assert_response :success
  end

  test "should return errors for updating to empty title process" do
    patch api_process_path(@srs_process, format: :json), params: {process: {title: ""}}
    assert_response :unprocessable_entity
  end

  test "should update privat status" do
    patch update_private_status_api_process_path(@srs_process, format: :json), params: {private: !@srs_process.private}
    assert_response :success
  end

  test "should update_assignee" do
    patch update_assignee_api_process_path(@srs_process, format: :json), params: {assignee: @current_user.id}
    assert_response :success
  end

  test "should allow removing assignee" do
    patch update_assignee_api_process_path(@srs_process, format: :json), params: {assignee: nil}
    assert_response :success
  end

  test "should update_contributors" do
    patch update_contributors_api_process_path(@srs_process, format: :json), params: {contributors: User.all.limit(3).pluck(:id)}
    assert_response :success
  end

  test "should allow removing all contributors" do
    patch update_contributors_api_process_path(@srs_process, format: :json), params: {contributors: [nil]}
    assert_response :success
  end

  test "should add comments to ambition" do
    assert_difference -> { Comment.count } do
      post comment_api_process_path(@srs_process, format: :json), params: {message: "Ein neuer Kommentar"}
    end
    assert_response :success
  end

  test "should update_ambitions" do
    patch update_ambitions_api_process_path(@srs_process, format: :json), params: {ambitions: Ambition.all.limit(3).pluck(:id)}
    assert_response :success
  end

  test "should allow removing all ambitions" do
    patch update_ambitions_api_process_path(@srs_process, format: :json), params: {ambitions: [nil]}
    assert_response :success
  end

  test "should create new processes" do
    process_definition_id = @srs_process.process_definition
    assert_difference -> { Workflow::Process.count } do
      post api_processes_path(process_definition_id: process_definition_id, format: :json)
    end
    assert_response :success
  end

  test "should create new processes with ambition and predecessor" do
    params = {
      process_definition_id: @srs_process.process_definition,
      ambition_id: Ambition.first.id,
      predecessor_process_id: @srs_process.id
    }

    assert_difference -> { Workflow::Process.count } do
      post api_processes_path(params.merge(format: :json))
    end
    assert_response :success
  end

  test "should cancel process" do
    patch cancel_api_process_path(@srs_process, format: :json), params: {cancel_info: "Is a required field for canceling"}
    assert_response :success
  end

  # Access Forbidden Tests - should be compacted and/or moved to different test

  test "no_access_user shouldn't be able to show a process" do
    login_as(@no_access_user)
    get api_process_url(@srs_process, format: :json)
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to cancel a process" do
    login_as(@no_access_user)
    patch cancel_api_process_url(@srs_process, format: :json), params: {cancel_info: "test canceling"}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to update (title and description) of a process" do
    login_as(@no_access_user)
    patch api_process_url(@srs_process, format: :json), params: {title: "updated title", description: "updated description"}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to update private status of a process" do
    login_as(@no_access_user)
    patch update_private_status_api_process_url(@srs_process, format: :json), params: {private: true}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to set or unset the assignee of a process" do
    login_as(@no_access_user)
    patch update_assignee_api_process_url(@srs_process, format: :json), params: {assignee: @no_access_user.id}
    assert_response :forbidden

    patch update_assignee_api_process_url(@srs_process, format: :json), params: {assignee: nil}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to update the contributors of a process" do
    login_as(@no_access_user)
    patch update_contributors_api_process_url(@srs_process, format: :json), params: {contributors: [@no_access_user.id]}
    assert_response :forbidden
  end
end

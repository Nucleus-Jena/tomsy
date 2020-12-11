require "test_helper"

class Api::TasksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @current_user = User.find_by!(email: "srs_user@example.org")
    @no_access_user = User.find_by!(email: "no_access_user@example.org")

    @srs_process = Workflow::Process.find_by!(title: "srs-process")
    @srs_task = @srs_process.tasks.find { |t| t.key == "set_reference_from_genese" }

    login_as(@current_user)
  end

  test "index of tasks should work" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get api_tasks_url(format: :json)
    assert_response :success
  end

  test "index of tasks for my marked tasks should work" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get api_tasks_url(tab_category: "MARKED", format: :json)
    assert_response :success
  end

  test "index of tasks with full filters should work" do
    CustomElasticSearchConfig.initalize_searchkick_indexes

    params = {
      page: 1,
      assignee_ids: [@current_user.id],
      contributor_ids: User.all.limit(3).pluck(:id),
      process_definition_ids: [@srs_process.process_definition.id],
      ambition_ids: Ambition.all.limit(5).pluck(:id),
      tab_category: "STARTED",
      task_definition_ids: [@srs_task.task_definition.id],
      order: "desc"
    }

    get api_tasks_url(params.merge(format: :json))
    assert_response :success
  end

  test "list of tasks should work" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get list_api_tasks_url(format: :json)
    assert_response :success
  end

  test "list of tasks should work with filters" do
    CustomElasticSearchConfig.initalize_searchkick_indexes
    get list_api_tasks_url(format: :json), params: {except: [@srs_task.id], query: "srs"}
    assert_response :success
  end

  test "should show task" do
    get api_task_url(@srs_task, format: :json)
    assert_response :success
  end

  test "should update_assignee" do
    patch update_assignee_api_task_path(@srs_task, format: :json), params: {assignee: @current_user.id}
    assert_response :success
  end

  test "should allow removing assignee" do
    patch update_assignee_api_task_path(@srs_task, format: :json), params: {assignee: nil}
    assert_response :success
  end

  test "should update_contributors" do
    patch update_contributors_api_task_path(@srs_task, format: :json), params: {contributors: User.all.limit(3).pluck(:id)}
    assert_response :success
  end

  test "should allow removing all contributors" do
    patch update_contributors_api_task_path(@srs_task, format: :json), params: {contributors: []}
    assert_response :success
  end

  test "update description of a task" do
    patch api_task_url(@srs_task, format: :json), params: {task: {description: "updated description"}}
    assert_response :success
  end

  test "update due date of a task" do
    patch update_due_date_api_task_url(@srs_task, format: :json), params: {due_at: Date.today}
    assert_response :success
  end

  test "remove due date of a task" do
    patch update_due_date_api_task_url(@srs_task, format: :json), params: {due_at: nil}
    assert_response :success
  end

  test "should get process activities" do
    get activities_api_task_url(@srs_task, format: :json)
    assert_response :success
  end

  test "mark a task" do
    patch update_marked_api_task_url(@srs_task, format: :json), params: {marked: true}
    assert_response :success
  end

  test "complete a task" do
    new_process, = Workflow::Process.create_from_definition(
      Workflow::ProcessDefinition.find_by!(key: "initial_meeting_invention")
    )
    new_process.update(assignee: @current_user)
    new_task = new_process.tasks.first

    patch complete_api_task_url(new_task, format: :json)
    assert_response :success
  end

  test "should add comments" do
    assert_difference -> { Comment.count } do
      post comment_api_task_url(@srs_task, format: :json), params: {message: "Ein neuer Kommentar"}
    end
    assert_response :success
  end

  test "get and update business data of a task" do
    get data_api_task_url(@srs_task, format: :json)
    assert_response :success
    patch data_api_task_url(@srs_task, format: :json), params: {reference: "test reference"}
    assert_response :success
  end

  test "create a document of type link on a task" do
    @srs_description_task = Workflow::Task.find(68)
    post create_document_api_task_url(@srs_description_task, format: :json), params: {
      title: "test file doc", type: "link", data_entity_field: "description_files", link_url: "https://example.org/file.html"
    }
    assert_response :success
  end

  test "create a document of type file on a task" do
    @srs_description_task = Workflow::Task.find(68)

    fixture_file = fixture_file_upload("files/cairo-multiline.pdf", "application/pdf")
    post create_document_api_task_url(@srs_description_task), as: :json, params: {
      title: "Ein Test Upload", type: "file", data_entity_field: "description_files", file: fixture_file
    }
    assert_response :success
  end

  test "update a document of a task" do
    fixture_file = fixture_file_upload("files/cairo-multiline.pdf", "application/pdf")
    document = @srs_task.process.data_entity.description_files.first
    patch update_document_api_task_url(@srs_task), as: :json, params: {
      document_id: document.id,
      title: "test file doc",
      file: fixture_file
    }
    assert_response :success
  end

  test "remove a document of a task" do
    document = @srs_task.process.data_entity.description_files.first
    delete destroy_document_api_task_url(@srs_task, format: :json), params: {document_id: document.id}
    assert_response :success
  end

  # Access Forbidden Tests

  test "no_access_user shouldn't be able to assign a user to a task" do
    login_as(@no_access_user)
    patch update_assignee_api_task_url(@srs_task, format: :json), params: {assignee: @no_access_user.id}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to update the contributors of a task" do
    login_as(@no_access_user)
    patch update_contributors_api_task_url(@srs_task, format: :json), params: {contributors: [@no_access_user.id]}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to update description of a task" do
    login_as(@no_access_user)
    patch api_task_url(@srs_task, format: :json), params: {description: "updated description"}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to update due date of a task" do
    login_as(@no_access_user)
    patch update_due_date_api_task_url(@srs_task, format: :json), params: {due_at: Date.today}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to get and update business data of a task" do
    login_as(@no_access_user)
    get data_api_task_url(@srs_task, format: :json)
    assert_response :forbidden
    patch data_api_task_url(@srs_task, format: :json), params: {reference: "test reference"}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to complete a task" do
    login_as(@no_access_user)
    patch complete_api_task_url(@srs_task, format: :json)
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to mark a task" do
    login_as(@no_access_user)
    patch update_marked_api_task_url(@srs_task, format: :json), params: {marked: true}
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to create a document of type file on a task" do
    login_as(@no_access_user)
    fixture_file = fixture_file_upload("files/cairo-multiline.pdf", "application/pdf")
    post create_document_api_task_url(@srs_task, format: :json), params: {
      title: "test file doc", type: "file", data_entity_field: "description_files", file: fixture_file
    }
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to update a document of a task" do
    login_as(@no_access_user)
    fixture_file = fixture_file_upload("files/cairo-multiline.pdf", "application/pdf")
    document = @srs_task.process.data_entity.description_files.first
    patch update_document_api_task_url(@srs_task, format: :json), params: {
      document_id: document.id,
      title: "test file doc",
      file: fixture_file
    }
    assert_response :forbidden
  end

  test "no_access_user shouldn't be able to remove a document of a task" do
    login_as(@no_access_user)
    document = @srs_task.process.data_entity.description_files.first
    delete destroy_document_api_task_url(@srs_task, format: :json), params: {document_id: document.id}
    assert_response :forbidden
  end
end

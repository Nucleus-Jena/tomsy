class Api::TasksController < ApiController
  load_and_authorize_resource class: "Workflow::Task", except: [:list, :activities, :update_due_date, :comment, :show_data, :update_data, :create_document, :update_document, :destroy_document]

  def index
    page = params[:page]&.to_i || 1
    assignee_ids = params[:assignee_ids] ||= []
    contributor_ids = params[:contributor_ids] ||= []
    process_definition_ids = params[:process_definition_ids] ||= []
    ambition_ids = params[:ambition_ids] ||= []
    tab_category = params[:tab_category] ||= "STARTED"
    task_definition_ids = params[:task_definition_ids] ||= []
    order = params[:order] ||= "desc"

    additional_query_params = {
      where: {
        _and: [
          {_or: assignee_ids.map { |id| {assignee_id: id} }},
          {_or: contributor_ids.map { |id| {contributor_ids: id} }},
          {_or: process_definition_ids.map { |id| {process_definition_id: id} }},
          {_or: ambition_ids.map { |id| {ambition_ids: id} }},
          {_or: task_definition_ids.map { |id| {task_definition_id: id} }}
        ],
        tab_categories: tab_category
      },
      order: {created_at: order.to_sym},
      page: page, per_page: 10
    }

    additional_query_params[:where][:marked_by_user_ids] = current_user.id if tab_category == "MARKED"

    @users = User.order_by_name_with_user_first(current_user).all

    @process_definitions = Workflow::ProcessDefinition.search_for_index(current_user, "*", {execute: false})
    @ambitions = Ambition.search_for_index(current_user, "*", false, {execute: false})

    @marked_count = Workflow::Task.marked_count_query(current_user, additional_query_params)
    @result = Workflow::Task.search_for_index(current_user, "*", true, additional_query_params.merge({execute: false}))

    Searchkick.multi_search([@result, @marked_count, @process_definitions, @ambitions])
  end

  def list
    excluded_task_ids = params[:except].to_a
    query = params[:query].blank? ? "*" : params[:query]

    additional_query_params = {
      where: {
        id: {not: excluded_task_ids}
      },
      order: {id_sort: :desc}
    }

    @tasks = Workflow::Task.search_for_list(current_user, query, additional_query_params)
  end

  def show
    @process = @task.process
    render "api/processes/show"
  end

  def activities
    set_task
    authorize!(:read, @task)

    @comments = @task.comments
    @events = @task.events_with_data_changes

    render "api/activities/index"
  end

  def update
    if Interactors::TaskInteractor.update(@task, task_params, current_user)
      @process = @task.process
      render "api/processes/show"
    else
      render json: @task.errors.messages, status: :unprocessable_entity
    end
  end

  def update_assignee
    if Interactors::TaskInteractor.update_assignee(@task, User.find_by(id: params.fetch(:assignee)), current_user)
      @process = @task.process
      render "api/processes/show"
    else
      render json: @task.errors.messages, status: :unprocessable_entity
    end
  end

  def update_contributors
    if Interactors::TaskInteractor.update_contributors(@task, User.where(id: params.fetch(:contributors)), current_user)
      @process = @task.process
      render "api/processes/show"
    else
      render json: @process.errors.messages, status: :unprocessable_entity
    end
  end

  def update_marked
    if Interactors::TaskInteractor.update_marked(@task, params.fetch(:marked), current_user)
      head :ok
    else
      render json: @task.errors.messages, status: :unprocessable_entity
    end
  end

  def update_due_date
    set_task
    authorize!(:update, @task)

    if Interactors::TaskInteractor.update_due_at(@task, params.fetch(:due_at), current_user)
      @process = @task.process
      render "api/processes/show"
    else
      render json: @task.errors.messages, status: :unprocessable_entity
    end
  end

  def complete
    if Interactors::TaskInteractor.complete(@task, current_user)
      @process = @task.process
      render "api/processes/show"
    else
      render json: @task.errors.messages, status: :unprocessable_entity
    end
  end

  def comment
    set_task
    authorize!(:update, @task)

    comment = Interactors::CommentInteractor.create(params.require(:message), @task, current_user)
    if comment.errors.none?
      @process = @task.process
      render "api/processes/show"
    else
      render json: comment.errors.messages, status: :unprocessable_entity
    end
  end

  ##################################
  # data entity stuff
  ##################################
  def show_data
    set_task
    authorize!(:read, @task)

    @data_attributes = @task.data_attributes(current_user)
    @data_entity = @task.process.data_entity
  end

  def update_data
    set_task
    authorize!(:data, @task)

    if Interactors::TaskInteractor.update_data(@task, task_data_params(@task), current_user)
      @process = @task.process
      render "api/processes/show"
    else
      render json: @task.process.data_entity.errors.messages, status: :unprocessable_entity
    end
  end

  def create_document
    set_task
    authorize!(:data, @task)

    document = Interactors::TaskInteractor.create_document(@task, document_params, current_user)
    if document.errors.none?
      @process = @task.process
      render "api/processes/show"
    else
      render json: document.errors.messages, status: :unprocessable_entity
    end
  end

  def update_document
    set_task
    authorize!(:data, @task)

    document = Document.find(params.require(:document_id))
    document = Interactors::TaskInteractor.update_document(@task, document, document_params(document.type), current_user)
    if document.errors.none?
      @process = @task.process
      render "api/processes/show"
    else
      render json: document.errors.messages, status: :unprocessable_entity
    end
  end

  def destroy_document
    set_task
    authorize!(:data, @task)

    document = Interactors::TaskInteractor.destroy_document(@task, Document.find(params.require(:document_id)), current_user)
    if document.errors.none?
      @process = @task.process
      render "api/processes/show"
    else
      render json: document.errors.messages, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:description)
  end

  def task_data_params(task)
    params.permit(task.process.data_entity.class.permit_attributes(task.key))
  end

  def document_params(type = nil)
    fields = [:title]
    fields += [:type, :data_entity_field] unless type

    case (type || params.require(:type))
    when Document::LINK
      fields += [:link_url]
    when Document::FILE
      fields += [:file]
    else
      raise "Unsupported document type"
    end

    params.permit(fields)
  end

  def set_task
    @task = Workflow::Task.find(params.require(:id))
  end
end

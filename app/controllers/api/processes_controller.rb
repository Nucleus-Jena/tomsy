class Api::ProcessesController < ApiController
  load_and_authorize_resource class: "Workflow::Process", except: [:activities, :create, :update_ambitions, :comment, :list]

  def index
    page = params[:page]&.to_i || 1
    query = params[:query].blank? ? "*" : params[:query]
    assignee_ids = params[:assignee_ids] ||= []
    contributor_ids = params[:contributor_ids] ||= []
    process_definition_ids = params[:process_definition_ids] ||= []
    ambition_ids = params[:ambition_ids] ||= []
    tab_category = params[:tab_category] ||= "RUNNING"
    order = params[:order] ||= "desc"

    additional_query_params = {
      where: {
        _and: [
          {_or: assignee_ids.map { |id| {assignee_id: id} }},
          {_or: contributor_ids.map { |id| {contributor_ids: id} }},
          {_or: process_definition_ids.map { |id| {process_definition_ids: id} }},
          {_or: ambition_ids.map { |id| {ambition_ids: id} }}
        ],
        tab_categories: tab_category
      },
      order: {created_at: order.to_sym},
      page: page, per_page: 10
    }

    @users = User.order_by_name_with_user_first(current_user).all

    @process_definitions = Workflow::ProcessDefinition.search_for_index(current_user, "*", {execute: false})
    @ambitions = Ambition.search_for_index(current_user, "*", false, {execute: false})

    @result = Workflow::Process.search_for_index(current_user, query, true, additional_query_params.merge({execute: false}))

    Searchkick.multi_search([@result, @process_definitions, @ambitions])
  end

  def list
    excluded_process_ids = params[:except].to_a
    query = params[:query].blank? ? "*" : params[:query]

    additional_query_params = {
      where: {
        id: {not: excluded_process_ids}
      },
      order: {id_sort: :desc}
    }

    @processes = Workflow::Process.search_for_list(current_user, query, additional_query_params)
  end

  def show
  end

  def activities
    set_process
    authorize!(:read, @process)

    @comments = @process.comments
    @events = Event.where(object: @process)

    render "api/activities/index"
  end

  def update
    if Interactors::ProcessInteractor.update(@process, process_params, current_user)
      render :show
    else
      render json: @process.errors.messages, status: :unprocessable_entity
    end
  end

  def update_private_status
    if Interactors::ProcessInteractor.update_private_status(@process, params.fetch(:private), current_user)
      render :show
    else
      render json: @process.errors.messages, status: :unprocessable_entity
    end
  end

  def update_assignee
    if Interactors::ProcessInteractor.update_assignee(@process, User.find_by(id: params.fetch(:assignee)), current_user)
      render :show
    else
      render json: @process.errors.messages, status: :unprocessable_entity
    end
  end

  def update_contributors
    if Interactors::ProcessInteractor.update_contributors(@process, User.where(id: params.fetch(:contributors)), current_user)
      render :show
    else
      render json: @process.errors.messages, status: :unprocessable_entity
    end
  end

  def update_ambitions
    set_process
    authorize!(:update, @process)

    if Interactors::ProcessInteractor.update_ambitions(@process, Ambition.where(id: params.fetch(:ambitions)), current_user)
      head :ok
    else
      render json: @process.errors.messages, status: :unprocessable_entity
    end
  end

  def create
    process_definition = Workflow::ProcessDefinition.find(params.require(:process_definition_id))
    authorize!(:create, process_definition.processes.new)

    ambition = Ambition.find_by(id: params[:ambition_id])
    predecessor_process = Workflow::Process.find_by(id: params[:predecessor_process_id])

    process = Interactors::ProcessInteractor.create(process_definition, ambition, predecessor_process, current_user)
    if process.errors.none?
      render partial: "api/processes/process_minimal", object: process, as: "process"
    else
      render json: process.errors.messages, status: :unprocessable_entity
    end
  end

  def cancel
    if Interactors::ProcessInteractor.cancel(@process, params.fetch(:cancel_info), current_user)
      render :show
    else
      render json: @process.errors.messages, status: :unprocessable_entity
    end
  end

  def comment
    set_process
    authorize!(:update, @process)

    comment = Interactors::CommentInteractor.create(params.require(:message), @process, current_user)
    if comment.errors.none?
      render "api/processes/show"
    else
      render json: comment.errors.messages, status: :unprocessable_entity
    end
  end

  private

  def set_process
    @process = Workflow::Process.find(params.require(:id))
  end

  def process_params
    params.require(:process).permit(:title, :description)
  end
end

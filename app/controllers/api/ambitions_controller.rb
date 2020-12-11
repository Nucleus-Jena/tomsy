class Api::AmbitionsController < ApiController
  load_and_authorize_resource except: [:index, :list, :activities, :update_assignee, :update_processes, :close, :reopen, :comment]

  def index
    page = params[:page]&.to_i || 1
    query = params[:query].blank? ? "*" : params[:query]
    assignee_ids = params[:assignee_ids] ||= []
    contributor_ids = params[:contributor_ids] ||= []
    process_definition_ids = params[:process_definition_ids] ||= []
    tab_category = params[:tab_category] ||= "OPEN"
    order = params[:order] ||= "desc"

    additional_query_params = {
      where: {
        _and: [
          {_or: assignee_ids.map { |id| {assignee_id: id} }},
          {_or: contributor_ids.map { |id| {contributor_ids: id} }},
          {_or: process_definition_ids.map { |id| {process_definition_ids: id} }}
        ],
        tab_categories: tab_category
      },
      order: {created_at: order.to_sym},
      page: page, per_page: 10
    }

    @users = User.order_by_name_with_user_first(current_user).all

    @process_definitions = Workflow::ProcessDefinition.search_for_index(current_user, "*", {execute: false})

    @result = Ambition.search_for_index(current_user, query, true, additional_query_params.merge({execute: false}))

    Searchkick.multi_search([@result, @process_definitions])
  end

  def list
    excluded_ambition_ids = params[:except].to_a
    query = params[:query].blank? ? "*" : params[:query]

    additional_query_params = {
      where: {
        id: {not: excluded_ambition_ids}
      },
      order: {title: :asc}
    }

    @result = Ambition.search_for_list(current_user, query, additional_query_params)
  end

  def show
    if @ambition.deleted
      head :gone
    else
      :show
    end
  end

  def activities
    set_ambition
    authorize!(:read, @ambition)

    @comments = @ambition.comments
    @events = Event.where(object: @ambition)

    render "api/activities/index"
  end

  def update
    if Interactors::AmbitionInteractor.update(@ambition, ambition_params, current_user)
      render :show
    else
      render json: @ambition.errors.messages, status: :unprocessable_entity
    end
  end

  def update_private_status
    if Interactors::AmbitionInteractor.update_private_status(@ambition, params.fetch(:private), current_user)
      render :show
    else
      render json: @ambition.errors.messages, status: :unprocessable_entity
    end
  end

  def update_assignee
    set_ambition
    authorize!(:update, @ambition)

    if Interactors::AmbitionInteractor.update_assignee(@ambition, User.find_by(id: params.fetch(:assignee)), current_user)
      render :show
    else
      render json: @ambition.errors.messages, status: :unprocessable_entity
    end
  end

  def update_contributors
    if Interactors::AmbitionInteractor.update_contributors(@ambition, User.where(id: params.fetch(:contributors)), current_user)
      render :show
    else
      render json: @ambition.errors.messages, status: :unprocessable_entity
    end
  end

  def update_processes
    set_ambition
    authorize!(:update, @ambition)

    if Interactors::AmbitionInteractor.update_processes(@ambition, Workflow::Process.where(id: params.fetch(:processes)), current_user)
      head :ok
    else
      render json: @ambition.errors.messages, status: :unprocessable_entity
    end
  end

  def create
    ambition = Interactors::AmbitionInteractor.create(current_user, ambition_params)
    if ambition.errors.none?
      render partial: "api/ambitions/ambition_minimal", object: ambition, as: "ambition"
    else
      render json: ambition.errors.messages, status: :unprocessable_entity
    end
  end

  def close
    set_ambition
    authorize!(:toggle_completeness, @ambition)

    if Interactors::AmbitionInteractor.close(@ambition, current_user)
      render :show
    else
      render json: @ambition.errors.messages, status: :unprocessable_entity
    end
  end

  def reopen
    set_ambition
    authorize!(:toggle_completeness, @ambition)

    if Interactors::AmbitionInteractor.reopen(@ambition, current_user)
      render :show
    else
      render json: @ambition.errors.messages, status: :unprocessable_entity
    end
  end

  def destroy
    if Interactors::AmbitionInteractor.delete(@ambition, current_user)
      head :ok
    else
      render json: @ambition.errors.messages, status: :unprocessable_entity
    end
  end

  def comment
    set_ambition
    authorize!(:update, @ambition)

    comment = Interactors::CommentInteractor.create(params.require(:message), @ambition, current_user)
    if comment.errors.none?
      render "api/ambitions/show"
    else
      render json: comment.errors.messages, status: :unprocessable_entity
    end
  end

  private

  def set_ambition
    @ambition = Ambition.find(params.require(:id))
  end

  def ambition_params
    params.require(:ambition).permit(:title, :description)
  end
end

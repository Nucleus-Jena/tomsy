class Api::ProcessDefinitionsController < ApiController
  def index
    limit = params[:max_result_count]&.to_i || 10
    query = params[:query].blank? ? "*" : params[:query]

    additional_query_params = {
      limit: limit
    }

    @process_definitions = Workflow::ProcessDefinition.search_for_index(current_user, query, additional_query_params)
  end
end

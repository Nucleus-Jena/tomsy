class Api::DossiersController < ApiController
  def index
    page = params[:page]&.to_i || 1
    query = params[:query].blank? ? "*" : params[:query]
    definitions = params[:definitions] ||= []
    order = params[:order] ||= "desc"
    field = params[:field]
    field_query = params[:field_query]

    additional_query_params = {
      where: {
        _and: [
          {_or: definitions.map { |identifier| {definition_identifier: identifier} }}
        ]
      },
      order: {created_at: order.to_sym},
      page: page, per_page: 10
    }

    @dossier_definitions = DossierDefinition.all.order(label: :asc).to_a

    @dossier_fields = []
    @dossier_fields = DossierDefinition.where(identifier: definitions).flat_map(&:fields).map(&:label).uniq if definitions.any?

    if field_query.present? && @dossier_fields.include?(field)
      additional_query_params[:where][field] = {like: "%#{field_query}%"}
    end

    @result = Dossier.search_for_index(current_user, query, false, additional_query_params)
  end

  def list
    definition_identifier = params[:definition] ||= []
    excluded_dossier_ids = params[:except].to_a
    query = params[:query].blank? ? "*" : params[:query]

    additional_query_params = {
      where: {
        id: {not: excluded_dossier_ids},
        definition_identifier: definition_identifier
      },
      order: {title: :asc}
    }

    @result = Dossier.search_for_list(current_user, query, additional_query_params)
  end

  def show
    set_dossier

    if @dossier.deleted
      head :gone
    else
      :show
    end
  end

  def new
    dossier_definition = DossierDefinition.find(params.require(:dossier_definition_id))
    @dossier = Dossier.new(definition: dossier_definition)
  end

  def create
    dossier_definition = DossierDefinition.find(params.require(:dossier_definition_id))
    @dossier = Dossier.create(definition: dossier_definition, field_data: params.require(:field_data).to_unsafe_hash)
    if @dossier.valid?
      render json: {id: @dossier.id}
    else
      render json: @dossier.errors.messages, status: :unprocessable_entity
    end
  end

  def update
    set_dossier

    @dossier.set_field_value(params.require(:identifier), params.fetch(:value))
    if @dossier.save
      render :show
    else
      render json: @dossier.errors.messages, status: :unprocessable_entity
    end
  end

  def destroy
    set_dossier

    if @dossier.update(deleted: true)
      head :ok
    else
      render json: @dossier.errors.messages, status: :unprocessable_entity
    end
  end

  def show_references
    set_dossier

    if @dossier.deleted
      head :gone
    else
      @processes = Workflow::Process
        .where(id: Workflow::Process.search_for_list(current_user, "*", {limit: nil}).map(&:id))
        .where(data_entity_id: @dossier.references.select(:data_entity_id).group(:data_entity_id).map(&:data_entity_id)).order(id: :desc)
    end
  end

  private

  def set_dossier
    @dossier = Dossier.find(params.require(:id))
  end
end

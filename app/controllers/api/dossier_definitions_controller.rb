class Api::DossierDefinitionsController < ApiController
  def index
    @result = DossierDefinition.all
  end
end

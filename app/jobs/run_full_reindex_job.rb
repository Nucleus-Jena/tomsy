class RunFullReindexJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # For now we simply run *.reindex. Later we will have to use bulk reindexing with es-index promotion
    CustomElasticSearchConfig.initalize_searchkick_indexes
  end
end

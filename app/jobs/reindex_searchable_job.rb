# TODO: Replace this job by Searchkick::ReindexV2Job
class ReindexSearchableJob < ApplicationJob
  queue_as :default

  def perform(searchable)
    searchable.reindex
  end
end

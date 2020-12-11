# Global Searchkick configuration
Searchkick.index_prefix = "nuc_#{Rails.env}"

class CustomElasticSearchConfig
  def self.indexables
    # delay loading model until called to avoid loading issues
    ["Workflow::Task", "Workflow::Process", "Ambition", "Workflow::ProcessDefinition", "Dossier"].map(&:constantize)
  end

  def self.initalize_searchkick_indexes
    wait_for_api_version_response

    indexables.each do |indexable|
      reindex_model(indexable)
    end
  end

  def self.sync_all_indexes
    indexables.each { |indexable| indexable.searchkick_index.refresh }
  end

  def self.reindex_model(indexable, retries = 5)
    error_occurred = false
    retries.times do |run_number|
      timeout = run_number * 2 + 1
      begin
        error_occurred = false
        reindex_and_refresh(indexable)
        break
      rescue => error
        error_occurred = true
        puts "\nERROR on reindex_and_refresh: #{error.class} SLEEPING #{timeout}s"
        puts error.message
        sleep timeout
      end
    end
    reindex_and_refresh(indexable) if error_occurred # One last try and make sure an exception is raised in the end
  end

  def self.reindex_and_refresh(indexable)
    indexable.searchkick_index.delete if indexable.searchkick_index.exists?
    indexable.reindex
    indexable.searchkick_index.refresh # Force Elasticsearch to sync index NOW
  end

  def self.wait_for_api_version_response(retries = 5, puts_debugging = false)
    print "Waiting for ElasticSearch to come online: " if puts_debugging
    retries.times do |run_number|
      timeout = run_number * 2 + 1
      begin
        version = Searchkick.server_version
        puts " ElasticSearch #{version} is online." if puts_debugging
        break
      rescue
        print "." if puts_debugging
        sleep timeout
      end
      puts "WARNING: ElasticSearch Service not available!"
    end
  end
end

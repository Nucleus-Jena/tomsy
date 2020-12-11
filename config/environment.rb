# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

ActiveResource::Base.logger = Rails.logger

# Load Camunda and snyc processes (creates ProcessDefinition objects/entries) AFTER loading application
# otherwise we define models (i.e.) User without their dependecies (devise) or actual user.rb code in application
# in production/staging when cache_classes is true these are never reloaded and thus unusable
CamundaInitializer.new.start_and_init_camunda_engine

Raven.configure do |config|
  config.dsn = "configure-your-own-sentry-instance"
  config.environments = ["staging", "production"]
  release_revision_file = Rails.root.join("REVISION")
  config.release = File.read(release_revision_file).squish if File.exist?(release_revision_file)

  config.excluded_exceptions = [] # Until we run a live system we want to catch all possible errors
  # Used to be (default raven configuration):
  #
  # IGNORE_DEFAULT = [
  #   'AbstractController::ActionNotFound',
  #   'ActionController::InvalidAuthenticityToken',
  #   'ActionController::RoutingError',
  #   'ActionController::UnknownAction',
  #   'ActiveRecord::RecordNotFound',
  #   'CGI::Session::CookieStore::TamperedWithCookie',
  #   'Mongoid::Errors::DocumentNotFound',
  #   'Sinatra::NotFound',
  #   'ActiveJob::DeserializationError'
  # ].freeze

  # If you have added items to Rails’ log filtering, you can also make sure that those items are not sent to Sentry:
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end

# Based on production defaults
require Rails.root.join("config/environments/production")

Rails.application.configure do
  # To see more set to :debug temporarily
  # config.log_level = :debug
  config.log_level = :info

  # Email-Setup
  config.action_mailer.delivery_method = :test # No Mails on staging!
end

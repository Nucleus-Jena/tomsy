# Be sure to restart your server when you modify this file.

# We face several challenges when applying CSP:
# 1. external js-librarires (i.e. sentry exception tracker, Newrelic APM)
# 2. unsafe-eval by those or our librarires (vuej.js)

# to allow faster development for now we disable CSP in those cases.

Rails.application.config.content_security_policy do |policy|
  policy.script_src :self, :https, :unsafe_eval, :unsafe_inline

  # Report violations to our Exception Tracker
  policy.report_uri "configure-your-own-senry-instance" # we might want to add ?sentry_environment=#{Rails.env} and may deployed version later
end

Rails.application.config.content_security_policy_report_only = true

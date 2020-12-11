source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.5"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails"
# Use PostgreSQL as the database for Active Record
gem "pg"
# Use Puma as the app server
gem "puma"
# Use SCSS for stylesheets
gem "sassc-rails"
gem "sprockets", "<4"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
gem "mini_racer", platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
gem "image_processing", "~> 1.2"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

gem "haml-rails"

# Use Webpack to manage app-like JavaScript modules in Rails
gem "webpacker", "~> 5.x"

# GitHub flavored markdown parser
gem "commonmarker"

# Rails engine that provides an easy-to-use interface for managing your data
gem "rails_admin"

# Raven is a Ruby client for Sentry Exception Tracking
gem "sentry-raven"

# Intelligent search made easy with Rails and Elasticsearch
gem "searchkick"

# Flexible authentication solution for Rails with Warden.
gem "devise"
# Translations for the devise gem
gem "devise-i18n"
# The authorization Gem for Ruby on Rails.
gem "cancancan"

gem "kaminari"

gem "nokogiri"

group :development, :test do
  # Call 'binding.pry' anywhere in the code to stop execution and get a debugger console
  gem "awesome_print"
  gem "hirb"
  gem "map_by_method"
  gem "pry-byebug"
  gem "pry-rails"
  gem "standard" # Ruby Style Guide, with linter & automatic code fixer
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen"
  gem "web-console"

  gem "better_errors"
  gem "binding_of_caller"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"

  gem "rubycritic", require: false # A Ruby code quality reporter
  gem "rubycritic-small-badge", require: false # Self service small badge for Rubycritic

  # Stuff for our IDEs
  gem "solargraph" # A Ruby language server. http://solargraph.org/ - see above

  gem "bullet" # add https://github.com/flyerhzm/bullet as recommended by cancancan upgrade guide.

  # Deployment
  gem "capistrano", require: false
  gem "capistrano-bundler", require: false
  gem "capistrano-rails", require: false
  gem "capistrano-passenger", require: false
  gem "capistrano-rbenv", require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "minitest-retry" # Re-run system test when the test fails.

  gem "timecop"

  gem "simplecov", require: false # Code Coverage Reports
end

# ruby wrapper for Camunda API
gem "camunda", github: "Dietech-Group/camunda", ref: "7e5d0ac"
# gem 'camunda', '= 0.1.5', path: '../camunda/'

# Simple HTTP and REST client for Ruby, we use it for form data posts
gem "rest-client"

# A library for generating fake data such as names, addresses, and phone numbers.
gem "faker"

# Track changes to your rails models
gem "paper_trail"

# NewRelic application performance monitoring
gem "newrelic_rpm"

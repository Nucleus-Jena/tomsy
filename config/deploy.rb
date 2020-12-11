# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

set :application, "workos"
set :repo_url, "set-your-repo-url.git"

# Default value for :linked_files is []
append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets" # Sensible defaults
append :linked_dirs, "storage" # default for ActiveStorage Files
append :linked_dirs, "public/packs" # webpacker compiled assets - stops us to recompiling every time

# Cleanup old asset versions (enough for usual rollback)
set :keep_assets, 5

# Restart Passenger Webserver with touch method
set :passenger_restart_with_touch, true

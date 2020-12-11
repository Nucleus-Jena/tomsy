server "staging-server", roles: %w[app db web]

set :deploy_to, "/var/www/stage-workos"

# parses out the current branch you're on.
current_branch = begin
                   `git branch`.match(/\* (\S+)\s/m)[1]
                 rescue
                   nil
                 end

# use the branch specified as a param, then use branch defined in Gitlab CI, then use the current branch. If all fails use master branch
set :branch, ENV["branch"] || ENV["CI_COMMIT_REF_NAME"] || current_branch || "master"

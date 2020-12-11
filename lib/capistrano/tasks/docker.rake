namespace :custom do
  namespace :docker do
    desc "Restart all docker containers defined by docker-compose.yml"
    task :restart do
      on roles(:app) do
        within current_path.to_s do
          execute "docker-compose", "restart"
        end
      end
    end
  end
end

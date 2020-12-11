# This helper task is needed to reset the camunda engine on heroku because we can't restart the engine
namespace :camunda do
  desc "delete camunda docker container"
  task reset: :environment do
    Camunda::User.all.reject { |user| ["demo", "john", "mary", "peter"].include?(user.id) }.each do |user|
      user.destroy
    end

    Camunda::Group.all.reject { |group| ["accounting", "camunda-admin", "management", "sales"].include?(group.id) }.each do |group|
      Camunda::Authorization.all.select { |auth| auth.groupId == group.id }.each do |auth|
        auth.destroy
      end

      group.destroy
    end

    Camunda::Deployment.all.each do |deployment|
      Camunda::Deployment.delete(deployment.id, cascade: true, skipCustomListeners: true, skipIoMappings: true)
    end

    load_workos_workflows
  end
end

namespace :camunda do
  desc "delete camunda docker container"
  task :drop do
    Kernel.system("docker-compose", "down")
    sleep 2
  end
end

namespace :camunda do
  desc "start and init camunda docker container"
  task init: :environment do
    CamundaInitializer.new.start_and_init_camunda_engine
  end
end

# every time you execute 'rake db:drop' run 'camunda:drop' first
Rake::Task["db:drop"].enhance ["camunda:drop"]

# every time you execute 'rake db:seed' run 'camunda:drop' and 'camunda:init' first
Rake::Task["db:create"].enhance ["camunda:init"]

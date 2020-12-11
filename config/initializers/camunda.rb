# Add camunda datetime format
Time::DATE_FORMATS[:camunda] = "%Y-%m-%dT%H:%M:%S.%L%z"

# Configure Camunda Endpoint
class Camunda::Api < ActiveResource::Base
  # Note for docker deployments port must match the exposed port in docker-compose.yml
  self.site = ENV["CAMUNDA_SITE"] || "http://localhost:8080/engine-rest/"
  self.include_format_in_path = false

  self.user = "demo"
  self.password = "demo"
end

class CamundaInitializer
  def wait_for_api_to_come_online
    print "Waiting for Camunda API to come online "
    20.times do
      print "."
      camunda_api_version = Camunda::Api.new.version
      puts " Using API version #{camunda_api_version}" unless camunda_api_version.nil?
      break
    rescue
      sleep 2
    end
  end

  def delete_camunda_demo_workflows
    # Delete all demo deployments
    Camunda::Deployment.where(source: "process application").each do |deployment|
      puts "Delete demo deployment with id: #{deployment.id}"
      Camunda::Deployment.delete(deployment.id, cascade: true, skipCustomListeners: true, skipIoMappings: true)
    end
  end

  def load_workos_workflows(workflow_files = Dir[Rails.root.join("workflow/*.bpmn")])
    # Load all default Workflows
    deployment_url = URI.join(Camunda::Api.site, Camunda::Api.site.path, "deployment/", "create").to_s

    print "Checking #{workflow_files.count} bpmn files if present and up to date in camunda engine "
    workflow_files.each do |workflow_file_name|
      response = RestClient::Request.execute(method: :post, url: deployment_url,
                                             user: Camunda::Api.user, password: Camunda::Api.password,
                                             payload: {multipart: true,
                                                       "deployment-name": File.basename(workflow_file_name, ".*"),
                                                       "enable-duplicate-filtering": true,
                                                       data: File.new(workflow_file_name)})

      puts("\nFAILED: #{response}") && next unless response.code == 200

      response_hash = JSON.parse(response.body)
      name = response_hash["name"]
      deploy_time = Time.parse(response_hash["deploymentTime"])
      workflow_is_new = (Time.now - deploy_time) < 5
      puts "\nCamunda Workflow (File: #{File.basename(workflow_file_name)}) - SUCCESS loaded new or updated Workflow (#{name}): #{response_hash["links"].first["href"]}" if workflow_is_new
      Rails.logger.info "Camunda Workflow (File: #{File.basename(workflow_file_name)}) - Using Workflow (#{name}) from #{deploy_time}: #{response_hash["links"].first["href"]}"

    rescue => e
      puts_to_console_for_debugging(e, workflow_file_name)
    end
    puts "...DONE"
  end

  def sync_camunda_workflows_to_db
    print "Syncing Camunda Workflows to DB"
    Camunda::ProcessDefinition.where(latestVersion: true).each do |camunda_process_definition|
      Workflow::Parser.create_or_update_process_from_camunda(camunda_process_definition)
    rescue => e
      puts_to_console_for_debugging(e, camunda_process_definition)
    end
    puts "...DONE"
  end

  def start_docker_containers_if_needed
    return if Rails.env.eql?("production") # Docker Host is already setup and container running
    return if ENV["CI"] # Gitlab CI starts services (aka docker container) based on .gitlab-ci.yml

    camunda_container_running = `docker inspect -f '{{.State.Running}}' workos_camunda`.strip == "true"
    return if camunda_container_running

    puts "Camunda container not running. Starting docker containers..."
    raise "PLEASE INSTALL docker-compose" unless Kernel.system("which", "docker-compose")

    Kernel.system("docker-compose", "up", "-d")
  end

  def start_and_init_camunda_engine
    start_docker_containers_if_needed
    wait_for_api_to_come_online
    delete_camunda_demo_workflows
    load_workos_workflows
    sync_camunda_workflows_to_db if database_accessible?
  end

  def database_accessible?
    # only actually querying for a table checks if the database has been destroyed since rails process started (i.e. rails db:reset)
    ActiveRecord::Base.connection.tables.any? && Workflow::ProcessDefinition.table_exists?
  rescue ActiveRecord::NoDatabaseError
    false
  end

  def puts_to_console_for_debugging(exception, thingy)
    puts "\nEXCEPTION rescued: #{exception.class} #{exception}"
    puts "  for: #{thingy.inspect}"
    if ENV["DEBUG"]
      puts exception.backtrace
      puts exception.http_body if exception.respond_to?(:http_body)
    else
      puts "  Set environment DEBUG=true to see full Stacktrace\n"
    end
  end
end

# Boot docker container VERY early (i.e. even before fully loading rails app) as these are mere shell scripts (i.e. no ruby class loading issues)
CamundaInitializer.new.start_docker_containers_if_needed

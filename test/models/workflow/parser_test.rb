require "test_helper"

class ParserTest < ActiveSupport::TestCase
  test "parse process" do
    camunda_pd = Camunda::ProcessDefinition.where(latestVersion: true).first
    Workflow::Parser.create_or_update_process_from_camunda(camunda_pd)
  end
end

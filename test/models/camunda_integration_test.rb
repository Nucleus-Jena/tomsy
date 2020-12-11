require "test_helper"

class CamundaIntegrationTest < ActiveSupport::TestCase
  test "camunda engine should be reachable" do
    assert Camunda::Task.get(:count)
  end

  test "default workflow for process initial_meeting_invention should be loaded" do
    process_invention_workflow = Camunda::Deployment.all.find { |deployment| deployment.name == "initial_meeting_invention" }
    assert process_invention_workflow.present?
  end
end

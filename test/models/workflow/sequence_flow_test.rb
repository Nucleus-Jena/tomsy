require "test_helper"

class Workflow::SequenceFlowTest < ActiveSupport::TestCase
  test "modelling BPMN graphs should be possible" do
    process = Workflow::ProcessDefinition.create!(key: "a-process", name: "A process", label_prefix: "AP")
    first_task = Workflow::TaskDefinition.create!(key: "first-task", name: "First task", order: 1, process_definition: process)
    opening_p_gateway = Workflow::ParallelGatewayDefinition.create!(key: "parallel_gateway_1", name: "Open the gateway", process_definition: process)
    closing_p_gateway = Workflow::ParallelGatewayDefinition.create!(key: "parallel_gateway_2", name: "Close the gateway", process_definition: process)
    start = Workflow::StartEventDefinition.create!(key: "start", name: "StartEvent", process_definition: process)
    end_event = Workflow::EndEventDefinition.create!(key: "end", name: "EndEvent", process_definition: process)
    Workflow::SequenceFlow.create!(from_object: start, to_object: first_task, process_definition: process)
    Workflow::SequenceFlow.create!(from_object: first_task, to_object: opening_p_gateway, process_definition: process)
    parallel_tasks = (2..6).map { |i|
      task = Workflow::TaskDefinition.create!(key: "task_#{i}", name: "task #{i}", order: i + 2, process_definition: process)
      Workflow::SequenceFlow.create!(from_object: opening_p_gateway, to_object: task, process_definition: process)
      task
    }
    parallel_tasks.each { |task| Workflow::SequenceFlow.create!(from_object: task, to_object: closing_p_gateway, process_definition: process) }
    Workflow::SequenceFlow.create!(from_object: closing_p_gateway, to_object: end_event, process_definition: process)

    assert first_task.reload.outgoing
    assert_equal 5, opening_p_gateway.reload.to_flows.count
    assert_equal parallel_tasks.sort, opening_p_gateway.outgoing.sort
    assert_equal 5, closing_p_gateway.reload.from_flows.count
    assert_equal parallel_tasks.sort, closing_p_gateway.reload.incoming.sort
  end
end

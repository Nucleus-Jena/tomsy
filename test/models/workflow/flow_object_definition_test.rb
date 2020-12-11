require "test_helper"

class Workflow::FlowObjectDefinitionTest < ActiveSupport::TestCase
  test "creating different STI sublcasses should work" do
    assert Workflow::FlowObjectDefinition.create(key: 1, name: 1, type: Workflow::FlowObjectDefinition.name,
                                                 process_definition: Workflow::ProcessDefinition.first!)
    assert Workflow::TaskDefinition.create(key: 2, name: 2, process_definition: Workflow::ProcessDefinition.first!)
  end
end

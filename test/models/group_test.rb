require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "groups may have several process definitions associated but each only once" do
    group = Group.first
    assert_nothing_raised do
      group.process_definitions = Workflow::ProcessDefinition.all.to_a
    end

    assert_raises ActiveRecord::RecordNotUnique do
      group.process_definitions << Workflow::ProcessDefinition.first
    end
  end
end

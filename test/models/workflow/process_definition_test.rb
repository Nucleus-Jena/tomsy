require "test_helper"

class Workflow::ProcessDefinitionTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "label_prefix should follow formatting rules" do
    definition = Workflow::ProcessDefinition.new(key: "a-key", name: "a name", label_prefix: "AK")
    assert definition.valid?

    # Lower case should not be allowed
    definition.label_prefix = "ak"
    refute definition.valid?

    # Minimum 2 and max 4 letters
    definition.label_prefix = "AKAK"
    assert definition.valid?
    definition.label_prefix = "A"
    refute definition.valid?
    definition.label_prefix = "A" * 5
    refute definition.valid?

    # Only A-Z
    definition.label_prefix = "3A"
    refute definition.valid?
  end

  test "process defintions should be reindexed when visibility relevant changes occur" do
    @pd = Workflow::ProcessDefinition.first
    @pd.update(groups: [])
    @group = Group.first
    assert_enqueued_with(job: RunFullReindexJob) { @group.process_definitions << @pd } # More Users are allowed to see this pd
    assert_enqueued_with(job: RunFullReindexJob) { @group.users << User.last } # One more User is allowed to see this pd
  end

  test "destroying process definitions should work to allow deploying new workflow versions" do
    assert_nothing_raised do
      definition = Workflow::ProcessDefinition.find_by_key!("event_planning") # has processes with documents and notifications attached
      definition.destroy!
    end
  end
end

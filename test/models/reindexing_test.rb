require "test_helper"

class ReindexingTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "ambitions should be reindexed when visibility relevant changes occur such as membership in groups" do
    group = Group.first
    user = User.all.find { |u| !u.in?(group.users) }
    assert_enqueued_with(job: RunFullReindexJob) { UserGroup.create!(user: user, group: group) }
    assert_enqueued_with(job: RunFullReindexJob) { UserGroup.last.update(user: user) }
    assert_enqueued_with(job: RunFullReindexJob) { group.users.delete(user) }
  end

  test "ambitions should be reindexed when visibility relevant changes occur such as groups -> process definition associations" do
    group = Group.first
    definition = Workflow::ProcessDefinition.all.find { |pd| !pd.in?(group.process_definitions) }
    assert_enqueued_with(job: RunFullReindexJob) { group.process_definitions << definition }
    assert_enqueued_with(job: RunFullReindexJob) { group.process_definitions.delete(definition) }
  end
end

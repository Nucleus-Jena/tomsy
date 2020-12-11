require "test_helper"

class ReindexDataEntityJobTest < ActiveJob::TestCase
  test "running job should with data entity should work" do
    process, = Workflow::Process.create_from_definition(
      Workflow::ProcessDefinition.find_by!(key: "initial_meeting_invention")
    )
    process.ambitions << Ambition.create(title: "Blubb Ziel")
    assert_nothing_raised { ReindexSearchableJob.perform_now(process) }
  end
end

require "test_helper"

class RunFullReindexJobTest < ActiveJob::TestCase
  test "running job should work" do
    assert_nothing_raised { RunFullReindexJob.perform_now }
  end
end

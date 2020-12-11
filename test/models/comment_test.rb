require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "creating comments should work" do
    assert_nothing_raised do
      Comment.create!(message: "a message", author: User.first, object: Workflow::Task.first)
    end
  end
end

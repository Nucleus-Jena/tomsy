require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "a users mention label should consist of an @ and his name" do
    any_user = User.first
    internal_reference_for_mentioning = any_user.mention_label
    assert internal_reference_for_mentioning.match(any_user.name)
    assert "@", internal_reference_for_mentioning.first
  end
end

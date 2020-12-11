require "test_helper"

class DataChangeTest < ActiveSupport::TestCase
  test "it should find changes for any tracked model" do
    skip
    #     person = Person.create!(name: "Test One", email: "test-one@example.org")
    #
    #     assert DataChange.who_changed_it_last(person, :name)
  end

  test "it should find a new version for every change" do
    skip
    #     person = Person.new(name: "Test One", email: "test-one@example.org")
    #
    #     assert_difference -> { DataChange.all_changes(person, :name).count } do
    #       person.save!
    #     end
    #
    #     assert_difference -> { DataChange.all_changes(person, :name).count } do
    #       person.update!(name: "Test ONE")
    #     end
  end
end

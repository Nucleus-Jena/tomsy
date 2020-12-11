require "test_helper"

class WorkflowSupportConcernTest < ActiveSupport::TestCase
  test "including a concern should require implementing certain methods" do
    @concern_instance = WorkflowSupportConcernTestEmptyDummy.new
    @concern_class = @concern_instance.class

    assert_raises(WorkflowSupportException) { @concern_class.camunda_process_definition_key }
  end

  test "including concern in domain object should work" do
    @concern_instance = WorkflowSupportConcernTestFullDummy.first
    @concern_class = @concern_instance.class

    assert_nothing_raised { @concern_class.camunda_process_definition_key }
    assert_nothing_raised { @concern_class.field_is_task_attribute?(:field, :task_identifier) }
    assert_nothing_raised { @concern_instance.workflow_processes }

    assert_equal ["third_task"], @concern_class.tasks_for_field("decision_field")
  end
end

class WorkflowSupportConcernTestEmptyDummy < ApplicationRecord
  self.table_name = "users" # to kind of fake a real AR object
  include WorkflowSupport
end

class WorkflowSupportConcernTestFullDummy < ApplicationRecord
  self.table_name = "users" # to kind of fake a real AR object
  include WorkflowSupport

  def self.camunda_process_definition_key
    "camunda_process_key"
  end

  def self.define_task_attributes
    {
      first_task: [{date_field: :datetime}, {people_field: :has_many_persons}],
      second_task: [{files_field: :has_many_files}],
      third_task: [{decision_field: :boolean}],
      forth_task: [{string_field: :string}]
    }
  end
end

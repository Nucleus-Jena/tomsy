require "test_helper"

class Workflow::ProcessTest < ActiveSupport::TestCase
  test "processes may be created for all supported types" do
    ambition = Ambition.create!(title: "My very own Ambition")
    Workflow::ProcessDefinition.all.each do |definition|
      process, = Workflow::Process.create_from_definition(definition)
      process.ambitions << ambition
      assert process.persisted?
    end
  end

  test "after creating a process all tasks are created and a not persisted TaskCreatedEvent is returned for every task" do
    process_definition = Workflow::ProcessDefinition.find_by!(key: "patent_application")

    process, events = Workflow::Process.create_from_definition(process_definition)

    assert_equal process_definition.task_definitions.count, process.tasks.count
    assert_not_empty process.tasks.started # Some have been started by camunda already
    assert_not_empty process.tasks.created # Some are only created

    assert_equal process_definition.task_definitions.count, events.count { |e| e.is_a?(Events::TaskCreatedEvent) }

    assert_empty process.tasks.started & process.tasks.created
  end

  test "titles should be set automatically after creation and not be unique" do
    process, = Workflow::Process.create_from_definition(Workflow::ProcessDefinition.find_by!(key: "patent_application"))
    second_process, = Workflow::Process.create_from_definition(Workflow::ProcessDefinition.find_by!(key: "patent_application"))
    process_with_different_data_entity, = Workflow::Process.create_from_definition(Workflow::ProcessDefinition.find_by!(key: "event_planning"))

    assert process.reload.title.present?
    assert_match(/[A-Z]*-\d*/, process.title)

    process.title = ""

    refute process.valid?

    a_title = "Hey ho - titel können beliebig sein!"

    process.title = a_title
    assert process.save!

    second_process.title = a_title
    assert second_process.valid?
    assert second_process.save!

    process_with_different_data_entity.title = a_title
    assert process_with_different_data_entity.save!
  end

  test "destroying a process should be possible to allow deploying new workflow versions" do
    process = Workflow::Process.find(13) # A process with attached files and comments triggering notifications

    assert_nothing_raised do
      process.destroy!
    end
    # Check all events/notifications for invalid data
    assert_nothing_raised do
      Event.all.map(&:type)
      Event.all.map(&:data)
    end
  end
end

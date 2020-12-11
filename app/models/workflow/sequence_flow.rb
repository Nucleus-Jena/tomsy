class Workflow::SequenceFlow < ApplicationRecord
  belongs_to :from_object, foreign_key: "from_object_id", class_name: "Workflow::FlowObjectDefinition", polymorphic: true
  belongs_to :to_object, foreign_key: "to_object_id", class_name: "Workflow::FlowObjectDefinition", polymorphic: true
  belongs_to :process_definition, foreign_key: "workflow_process_definition_id", class_name: "Workflow::ProcessDefinition"
end

class Workflow::FlowObjectDefinition < ApplicationRecord
  belongs_to :process_definition, class_name: "Workflow::ProcessDefinition", foreign_key: "workflow_process_definition_id"

  has_many :to_flows, foreign_key: "from_object_id", class_name: "Workflow::SequenceFlow"
  has_many :from_flows, foreign_key: "to_object_id", class_name: "Workflow::SequenceFlow"

  # has_many through does not work with polymorphic targets (a single source_type must be specified)
  def outgoing
    to_flows.map(&:to_object)
  end

  def incoming
    from_flows.map(&:from_object)
  end

  validates :key, presence: true
  validates :name, presence: true
  validates :process_definition, presence: true
end

class Workflow::StartEventDefinition < Workflow::FlowObjectDefinition; end
class Workflow::EndEventDefinition < Workflow::FlowObjectDefinition; end
class Workflow::ParallelGatewayDefinition < Workflow::FlowObjectDefinition; end
class Workflow::ExclusiveGatewayDefinition < Workflow::FlowObjectDefinition; end

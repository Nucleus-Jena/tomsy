class Workflow::TaskDefinition < Workflow::FlowObjectDefinition
  has_many :tasks, class_name: "Workflow::Task", foreign_key: "workflow_task_definition_id", inverse_of: :task_definition, dependent: :destroy

  validates :order, presence: true
end

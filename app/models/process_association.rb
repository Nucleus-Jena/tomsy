class ProcessAssociation < ApplicationRecord
  belongs_to :process, class_name: "Workflow::Process", foreign_key: "process_id"
  belongs_to :data_entity, polymorphic: true

  scope :for_field, ->(field) { where(data_entity_field: field.to_s).order(:id) }
  scope :for_type, ->(type) { where(data_entity_type: type.to_s) }
end

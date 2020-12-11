class DossierAssociation < ApplicationRecord
  belongs_to :dossier
  belongs_to :data_entity, polymorphic: true

  scope :for_field, ->(field) { where(data_entity_field: field.to_s).order(:id) }
  scope :for_type, ->(type) { where(data_entity_type: type.to_s) }
end

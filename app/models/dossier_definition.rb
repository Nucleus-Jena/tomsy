class DossierDefinition < ApplicationRecord
  has_many :fields, -> { order(:position) }, class_name: "DossierDefinitionField", foreign_key: "definition_id", dependent: :destroy, inverse_of: :definition
  has_many :dossiers, foreign_key: "definition_id", dependent: :destroy, inverse_of: :definition

  validates :identifier, :label, presence: true
  validates :identifier, format: {with: /\A[a-z0-9_]+\z/, message: "darf nur Kleinbuchstaben, Ziffern oder Unterstrische enthalten"}
  validates :identifier, uniqueness: {case_sensitive: false}
  validate :validate_unchangeable_fields, on: :update
  validate :validate_title_fields
  validate :validate_subtitle_fields

  # for rails admin
  accepts_nested_attributes_for :fields, allow_destroy: true

  # for rails admin
  def name
    "(##{id}, #{identifier}) #{label}"
  end

  private

  def validate_unchangeable_fields
    errors.add(:identifier, "kann nicht geändert werden") if identifier_changed?
  end

  def validate_title_fields
    if title_fields.is_a?(Array)
      title_fields.each do |field|
        unless fields.where(identifier: field).exists?
          errors.add(:title_fields, "referenziert das Feld (#{field}), welches in dieser Dossier Definition nicht existert")
        end
      end
    else
      errors.add(:title_fields, "muss ein Array von Feldern sein")
    end
  end

  def validate_subtitle_fields
    if subtitle_fields.is_a?(Array)
      subtitle_fields.each do |field|
        unless fields.where(identifier: field).exists?
          errors.add(:subtitle_fields, "referenziert das Feld (#{field}), welches in dieser Dossier Definition nicht existert")
        end
      end
    else
      errors.add(:subtitle_fields, "muss ein Array von Feldern sein")
    end
  end
end

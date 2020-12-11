class DossierDefinitionField < ApplicationRecord
  belongs_to :definition, class_name: "DossierDefinition", inverse_of: :fields

  validates :identifier, :label, :position, :content_type, presence: true
  validates :identifier, format: {with: /\A[a-z0-9_]+\z/, message: "darf nur Kleinbuchstaben, Ziffern oder Unterstrische enthalten"}
  validates :identifier, uniqueness: {scope: :definition_id, case_sensitive: false}
  validates :position, uniqueness: {scope: :definition_id}
  validate :validate_unchangeable_fields, on: :update

  scope :required_or_recommended, -> { where(required: true).or(where(recommended: true)) }

  enum content_type: [:string, :text, :integer, :boolean, :date]

  # for rails admin
  def name
    "(##{id}, #{identifier}) #{label}"
  end

  def cast_value(value)
    case content_type.to_sym
    when :string
      value&.to_s
    when :text
      value&.to_s
    when :integer
      ActiveModel::Type::BigInteger.new.cast(value)
    when :boolean
      ActiveModel::Type::Boolean.new.cast(value)
    when :date
      ActiveModel::Type::Date.new.cast(value)
    else
      raise "Unsupported dossier definition field content_type"
    end
  end

  def deserialize(value)
    case content_type.to_sym
    when :string
      value
    when :text
      value
    when :integer
      value
    when :boolean
      value
    when :date
      Date.parse(value)
    else
      raise "Unsupported dossier definition field content_type"
    end
  end

  def serialize(value)
    case content_type.to_sym
    when :string
      value
    when :text
      value
    when :integer
      value
    when :boolean
      value
    when :date
      value&.as_json
    else
      raise "Unsupported dossier definition field content_type"
    end
  end

  def validate(dossier)
    value = dossier.get_field_value(identifier)

    if required? && value.blank?
      dossier.errors.add("field_#{identifier}", "muss ausgefüllt werden")
    end

    if unique? && Dossier.where.not(id: dossier.id).where(definition: definition, deleted: false).where("data @> ?", {identifier.to_sym => value}.to_json).exists?
      dossier.errors.add("field_#{identifier}", "ist bereits vergeben")
    end
  end

  private

  def validate_unchangeable_fields
    errors.add(:identifier, "kann nicht geändert werden") if identifier_changed?
    errors.add(:definition, "kann nicht geändert werden") if definition_id_changed?
  end
end

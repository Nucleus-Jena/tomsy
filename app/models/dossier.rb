class Dossier < ApplicationRecord
  include AclSearchSupport
  include SearchForIndexWithCategories

  belongs_to :definition, class_name: "DossierDefinition", inverse_of: :dossiers
  belongs_to :created_by, class_name: "User", optional: true

  has_many :references, class_name: "DossierAssociation"
  has_many :data_entities, class_name: "ProcessDataEntity", through: :references, source_type: "ProcessDataEntity"

  validates :definition_id, presence: true
  validate :validate_unchangeable_fields, on: :update
  validate :validate_data, unless: -> { definition.nil? }

  searchkick language: "german", callbacks: :async, word_middle: [:title], suggest: [:title, :subtitle]
  scope :search_import, -> { where(deleted: false) }

  def should_index?
    !deleted
  end

  def field_data=(new_field_data)
    throw "field_data must be a hash" unless new_field_data.is_a?(Hash)

    @field_data = {}
    new_field_data.each { |key, value| set_field_value(key, value) }
  end

  def get_field_value(identifier)
    field_data[identifier]
  end

  def set_field_value(identifier, value)
    field_definition = definition.fields.find_by(identifier: identifier)
    return false unless field_definition

    field_data[identifier] = field_definition.cast_value(value)
    data[identifier] = field_definition.serialize(field_data[identifier])
  end

  def data_fields(required_and_recommended_only = false)
    definition_fields = definition.fields
    definition_fields = definition_fields.required_or_recommended if required_and_recommended_only
    definition_fields.map { |field| {definition: field, value: get_field_value(field.identifier)} }
  end

  def title
    field_values_to_text(definition.title_fields, [String(id), definition.label]) if definition
  end

  def subtitle
    field_values_to_text(definition.subtitle_fields, []) if definition
  end

  private

  def field_data
    return @field_data unless @field_data.nil?

    @field_data = {}
    definition.fields.each do |field_definition|
      field_raw_data_value = data[field_definition.identifier]
      @field_data[field_definition.identifier] = field_definition.deserialize(field_raw_data_value) unless field_raw_data_value.nil?
    end

    @field_data
  end

  def validate_unchangeable_fields
    errors.add(:definition, "kann nicht geändert werden") if definition_id_changed?
    errors.add(:created_by, "kann nicht geändert werden") if created_by_id_changed?
  end

  def validate_data
    if data&.is_a?(Hash)
      definition.fields.map { |field| field.validate(self) }
    else
      errors.add(:data, "muss ein Hash sein")
    end
  end

  def field_values_to_text(field_identifiers, default_values)
    elements = if field_identifiers.any?
      field_identifiers.map { |field_identifier| String(get_field_value(field_identifier)) }
    else
      default_values
    end

    elements.reject { |element| element.empty? }.join(" • ")
  end

  def data_fields_by_label
    data_fields.group_by { |df| df[:definition].label }.each_with_object({}) do |label_dfs, hash|
      label, dfs = label_dfs
      hash[label] = dfs.map { |df| " " + df[:value].to_s } # force ES to index as text
    end
  end

  def search_data
    {
      title: title,
      subtitle: subtitle,
      definition_identifier: definition.identifier,
      definition: definition.label,
      created_at: created_at
    }.merge(data_fields_by_label).merge(acl_search_restrictions)
  end
end

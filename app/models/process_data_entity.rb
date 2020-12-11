class ProcessDataEntity < ApplicationRecord
  validates_presence_of inheritance_column
  include WorkflowSupport
  include AssociationSupport
  include DataEntitySearch

  def get_task_result(task_identifier)
    task_result = process.process_definition.model["tasks"][task_identifier.to_s]
    return unless task_result["result_key"].present? && task_result["result_value"].present?

    {task_result["result_key"] => ActiveModel::Type.lookup(:boolean).cast(send(task_result["result_value"]))}
  end

  def self.define_task_attributes
    process_definition.model["tasks"].transform_values { |tv| (tv["fields"] || []).map { |f| {f["id"].to_sym => f["type"].to_sym} } }
  end

  def self.task_field_definitions(task_identifier)
    process_definition.model.dig("tasks", task_identifier, "fields") || []
  end

  def self.process_definition
    @process_definition ||= Workflow::ProcessDefinition.where("model->>'model_class' = ?", name).first
  end

  def self.field_definitions
    process_definition.model["tasks"].values.map { |t| t["fields"] }.compact.flatten
  end

  def self.field_definition(id)
    field_definitions.find { |f| f["id"] == id }
  end

  def self.simple_field_definitions
    field_definitions.reject { |f| f["type"] =~ /^has_/ }
  end

  def self.association_field_definitions
    field_definitions.select { |f| f["type"] =~ /^has_/ }
  end

  def self.dossier_association_field_definitions
    field_definitions.select { |f| f["type"] == "has_one_dossier" || f["type"] == "has_many_dossiers" }
  end

  def self.label_for(attr_name)
    # TODO: we might want to add options, as in human_attribute_name; for count etc.
    process_definition && field_definitions.find { |f| f["id"].to_s == attr_name }&.[]("label")
  end

  class <<self
    alias human_attribute_name_orig human_attribute_name
  end

  def self.human_attribute_name(attr_name, options = {})
    label_for(attr_name) || human_attribute_name_orig(attr_name, options)
  end

  def self.fields_loaded
    @fields_loaded ||= false
  end

  def self.reload_fields
    store_accessor(:data, *simple_field_definitions.map { |f| f["id"] })

    association_field_definitions.each do |f|
      send(f["type"], f["id"])
    end

    # false && # do not yet execute validations because they should only be added conditional based on the process later
    process_definition.model["tasks"].each_value do |task|
      task["fields"]&.each do |field|
        field_id = field["id"]
        field["validations"]&.each do |validation_type, config|
          case validation_type
          when "required"
            # TODO: validates_presence_of field_id # TODO: using presence in a late task may prevent early tasks from saving. Thus, this should probably depend on completeness of tasks.
          when "minlength"
            validates_length_of field_id, minimum: config, allow_blank: true
          when "maxlength"
            validates_length_of field_id, maximum: config
          when "min"
            validates field_id, numericality: {greater_than_or_equal_to: config}, allow_nil: true
          when "max"
            validates field_id, numericality: {less_than_or_equal_to: config}, allow_nil: true
          when "regex"
            validates field_id, format: {with: Regexp.new(config, Regexp::IGNORECASE)}, allow_blank: true
          end
        end
      end
    end
    @fields_loaded = true
  end

  def self.define_inheriting_model(class_name)
    mc = Object.const_set(class_name, Class.new(self))
    mc.reload_fields
    mc
  end

  def self.get_specific_model(class_name)
    if defined?(class_name)
      Object.const_get(class_name)
      # puts "FIELDS LOADED? #{mc.fields_loaded} -- #{mc.stored_attributes.inspect}"

    else
      define_inheriting_model(class_name)
    end
  rescue NameError
    define_inheriting_model(class_name)
  end

  def self.query_defined_subclasses
    ActiveRecord::Base.connection.execute("select distinct model->>'model_class' from workflow_process_definitions").values.flatten.compact
  end

  def self.query_used_subclasses
    ActiveRecord::Base.connection.execute("select distinct type from process_data_entities").values.flatten.compact
  end

  def self.subclasses
    if database_accessible?
      query_defined_subclasses | query_used_subclasses
    else
      []
    end
  end

  def self.unload_subclasses
    subclasses.select { |class_name| Object.const_defined?(class_name) }.each do |uc|
      Object.send(:remove_const, uc)
    end
  rescue Exception => e # rubocop:disable Lint/RescueException
    puts "Rails wanted to reload some classes, esp. ProcessDataEntity and so we need to unload all subclasses, but that failed somehow."
    raise e
  end

  def self.eager_load_subclasses
    subclasses.each { |class_name| ProcessDataEntity.define_inheriting_model(class_name) }
  end

  def self.database_accessible?
    # only actually querying for a table checks if the database has been destroyed since rails process started (i.e. rails db:reset)
    ActiveRecord::Base.connection.tables.any?
  rescue ActiveRecord::NoDatabaseError
    false
  end

  unload_subclasses # this unloads any subclasses from a *previous* lifecycle. This is needed for running in development mode (i.e. when cache_classes=false).
  eager_load_subclasses # needed for RailsAdmin; otherwise lazily loading would be sufficient
end

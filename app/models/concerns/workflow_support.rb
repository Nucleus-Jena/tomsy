require "active_support/concern"

module WorkflowSupport
  extend ActiveSupport::Concern

  included do
    has_many :workflow_processes, class_name: "Workflow::Process", as: :data_entity, dependent: :destroy

    has_paper_trail

    after_commit :reindex_process, on: :update

    # This must be implemented for processes/data_entities with workflows which branch due to conditions/results of tasks
    # The task results are posted to our workflow engine
    def get_task_result(task_identifier)
      nil
    end

    # We currently only support adding one Process per data entity
    def process
      workflow_processes.first
    end

    def name_for_api(field_def)
      attr_name = field_def["id"]
      attr_type = field_def["type"]

      case attr_type.to_sym
      when :has_one_dossier
        "#{attr_name}_id"
      when :has_many_dossiers
        "#{attr_name.singularize}_ids"
      else
        attr_name
      end
    end

    def parameter_for_api(field_def, user)
      attr_type = field_def["type"]
      parameter = field_def["parameter"]

      case attr_type.to_sym
      when :has_many_processes
        {
          startable_processes:
              Workflow::ProcessDefinition.where(key: parameter["startable_process_keys"]).map do |process_def|
                if user.can?(:create, Workflow::Process.new(process_definition: process.process_definition))
                  {id: process_def.id, name: process_def.name}
                else
                  {id: nil, name: "You do not have the rights to start this type of process."}
                end
              end
        }
      when :info
        info_attr = field_def["parameter"]["attribute"]
        if info_attr
          {
            valueType: self.class.field_definition(info_attr)["type"],
            valueParameter: parameter_for_api(self.class.field_definition(info_attr), user)
          }
        else
          {
            valueType: "text",
            valueParameter: nil
          }
        end
      else
        parameter
      end
    end

    def label_for_api(field_def)
      attr_name = field_def["id"]
      attr_type = field_def["type"]

      case attr_type.to_sym
      when :info
        info_attr = field_def["parameter"]["attribute"]
        result = self.class.label_for(attr_name)
        if info_attr
          result ||= label_for_api(self.class.field_definition(info_attr))
        end
        result
      else
        process.data_entity.class.human_attribute_name(attr_name)
      end
    end

    def value_for_api(field_def)
      attr_name = field_def["id"]
      attr_type = field_def["type"]

      case attr_type.to_sym
      when :info
        info_attr = field_def["parameter"]["attribute"]
        if info_attr
          value_for_api(self.class.field_definition(info_attr))
        else
          field_def["parameter"]["text"]
        end
      when :has_many_files
        Document.for_id(id).for_field(attr_name)
      when :has_one_file
        Document.for_id(id).for_field(attr_name)
      else
        send(attr_name)
      end
    end

    def data_for_task(task_identifier, user)
      self.class.task_field_definitions(task_identifier).map do |field_def|
        {
          name: name_for_api(field_def),
          type: field_def["type"],
          parameter: parameter_for_api(field_def, user),
          value: value_for_api(field_def),
          label: label_for_api(field_def)
        }
      end
    end

    def dossier_data_for_process
      self.class.dossier_association_field_definitions.map do |field_def|
        {
          name: name_for_api(field_def),
          type: field_def["type"],
          value: value_for_api(field_def),
          label: label_for_api(field_def)
        }
      end
    end

    def attributes_for_task_hash(task_identifier)
      Hash[self.class.task_attributes(task_identifier).map { |attr_name| [attr_name, send(attr_name)] }]
    end

    def reindex_process
      ReindexSearchableJob.perform_later(process)
    end
  end

  class_methods do
    def camunda_process_definition_key
      raise WorkflowSupportException, "Please define camunda_process_definition_key!"
    end

    def field_is_task_attribute?(field, task_identifier)
      return false unless task_identifier.present?

      task_attributes(task_identifier).include?(field)
    end

    def tasks_for_field(field)
      attributes = Hash.new([]).merge(define_task_attributes).with_indifferent_access
      attributes.select { |_task_identifier, fields| fields.flatten.map(&:keys).flatten.include?(field) }.map(&:first)
    end

    def define_task_attributes
      raise WorkflowSupportException, "Please define your task attributes!"
    end

    def task_attributes(task_identifier)
      attributes = Hash.new([]).merge(define_task_attributes).with_indifferent_access
      attributes[task_identifier].map { |v| v.is_a?(Hash) ? v.keys.first : v }
    end

    def data_attributes_with_type
      attributes = Hash.new([]).merge(define_task_attributes).with_indifferent_access
      Hash[attributes.values.flatten.map { |v| v.to_a.flatten }]
    end

    def permit_attributes(task_identifier)
      attributes = Hash.new([]).merge(define_task_attributes).with_indifferent_access
      attributes[task_identifier].map { |v| permit_attribute(v.keys.first, v.values.first) }
    end

    def permit_attribute(name, type)
      case type
      when :has_one_dossier
        "#{name}_id"
      when :has_many_dossiers
        {"#{name.singularize}_ids" => []}
      when :enum
        {name => []}
      else
        name
      end
    end
  end
end

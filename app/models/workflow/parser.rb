class Workflow::Parser
  attr_accessor :xml

  def initialize(xml)
    @xml = xml
  end

  def element_id(element)
    element.attributes["id"].value
  end

  def element_label(element)
    suffix = element.attributes["name"]&.value&.gsub(/\s/, " ").to_s
    element.name + "_" + suffix
  end

  def all_flows
    xml.xpath("/bpmn:definitions/bpmn:process/bpmn:sequenceFlow")
  end

  def find_element(flow_or_string, direction = :target)
    target_id = flow_or_string.is_a?(String) ? flow_or_string : flow_or_string.attr("#{direction}Ref")
    target = xml.xpath("/bpmn:definitions/bpmn:process/*[@id='#{target_id}']").first
    raise "Unsupported BPMN Element" unless target.name.in?(["startEvent", "sequenceFlow", "parallelGateway", "exclusiveGateway", "endEvent", "userTask"])
    target
  end

  def ruby_class_for_bpmn_element(element)
    case element.name
    when "startEvent" then Workflow::StartEventDefinition
    when "parallelGateway" then Workflow::ParallelGatewayDefinition
    when "exclusiveGateway" then Workflow::ExclusiveGatewayDefinition
    when "endEvent" then Workflow::EndEventDefinition
    when "userTask" then Workflow::TaskDefinition
    when "sequenceFlow" then Workflow::SequenceFlow
    else raise "Unsupported BPMN Element"
    end
  end

  def self.create_or_update_process_from_camunda(camunda_process_definition)
    process_definition = find_or_create_process_definition(camunda_process_definition)
    update_process_definition_basics(process_definition, camunda_process_definition)
    update_process_definition_tasks(process_definition, camunda_process_definition)

    update_process_definition_with_bpmn_graph(process_definition, camunda_process_definition)
    process_definition
  end

  def self.update_process_definition_with_bpmn_graph(process_definition, camunda_process_definition)
    xml_doc = Nokogiri::XML(camunda_process_definition.get("xml")["bpmn20Xml"])
    parser = new(xml_doc)

    parser.all_flows.each do |flow|
      from, to = [:source, :target].map { |direction|
        element = parser.find_element(flow["#{direction}Ref"], direction)
        key = parser.element_id(element)
        name = parser.element_label(element)
        type = parser.ruby_class_for_bpmn_element(element).name
        Workflow::FlowObjectDefinition.create_with(name: name)
          .find_or_create_by!(key: key, type: type, process_definition: process_definition)
      }
      Workflow::SequenceFlow.find_or_create_by!(from_object: from, to_object: to, process_definition: process_definition)
    end
  end

  def self.find_or_create_process_definition(camunda_process_definition)
    default_label_prefix = camunda_process_definition.key[0..1].upcase
    Workflow::ProcessDefinition.create_with(name: camunda_process_definition.name, label_prefix: default_label_prefix).find_or_create_by!(key: camunda_process_definition.key)
  end

  def self.update_process_definition_basics(process_definition, camunda_process_definition)
    xml_doc = Nokogiri::XML(camunda_process_definition.get("xml")["bpmn20Xml"])

    process_definition.update!(name: camunda_process_definition.name) unless process_definition.name == camunda_process_definition.name

    documentation = xml_doc.at_xpath("/bpmn:definitions/bpmn:process/bpmn:documentation")&.content
    process_definition.update!(description: documentation) unless process_definition.description == documentation

    label_prefix = xml_doc.at_xpath('/bpmn:definitions/bpmn:process/bpmn:extensionElements/camunda:properties/camunda:property[@name="label_prefix"]/@value')&.value
    process_definition.update!(label_prefix: label_prefix) unless process_definition.label_prefix == label_prefix

    model_class_name = xml_doc.at_xpath('/bpmn:definitions/bpmn:process/bpmn:extensionElements/camunda:properties/camunda:property[@name="model_class"]/@value')&.value
    process_definition.update!(model_class_name: model_class_name) unless process_definition.model_class_name == model_class_name
  end

  def self.update_process_definition_tasks(process_definition, camunda_process_definition)
    xml_doc = Nokogiri::XML(camunda_process_definition.get("xml")["bpmn20Xml"])

    process_definition.model["tasks"] ||= {}

    xml_doc.xpath("//bpmn:userTask").each do |user_task|
      key = user_task["id"]
      name = user_task["name"]
      order = user_task.xpath(".//bpmn:extensionElements//camunda:properties//camunda:property[@name='order']").first["value"]

      documentation = user_task.xpath(".//bpmn:documentation").first&.content

      form_data = user_task.xpath("bpmn:extensionElements/camunda:formData")
      if form_data.present?
        fields = form_data.xpath("camunda:formField").map { |form_field|
          field = {
            id: form_field["id"],
            label: form_field["label"],
            type: form_field.at_xpath('camunda:properties/camunda:property[@id="type"]/@value')&.value || form_field["type"],
            parameter: YAML.safe_load(form_field.at_xpath('camunda:properties/camunda:property[@id="parameter"]/@value')&.value || "null"),
            validations: {
              regex: form_field.at_xpath('camunda:properties/camunda:property[@id="validation_regex"]/@value')&.value
            }.merge(
              form_field.xpath("camunda:validation/camunda:constraint").map { |constraint| [constraint["name"], constraint["config"] || true] }.to_h
            ).compact
          }

          if field[:type] == "enum"
            field[:parameter] = {
              values: form_field.xpath("camunda:value").map { |v| {id: v["id"], label: v["name"]} }
            }
          end

          field
        }
      end

      process_definition.model["tasks"][key] = {
        fields: fields,
        result_key: user_task.at_xpath('bpmn:extensionElements/camunda:properties/camunda:property[@name="result_key"]/@value')&.value,
        result_value: user_task.at_xpath('bpmn:extensionElements/camunda:properties/camunda:property[@name="result_value"]/@value')&.value
      }.compact

      process_definition.save!

      task_definition = Workflow::TaskDefinition.create_with(name: name, description: documentation, order: order).find_or_create_by!(key: key, process_definition: process_definition)
      task_definition.update(name: name, description: documentation, order: order)
    end
  end
end

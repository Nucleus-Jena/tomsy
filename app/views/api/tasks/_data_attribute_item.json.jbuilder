json.name data_attribute[:name]
json.type data_attribute[:type]
json.parameter data_attribute[:parameter]
json.label data_attribute[:label]

case (data_attribute.dig(:parameter, :valueType) || data_attribute[:type]).to_sym
when :string
  json.value data_attribute[:value].to_s
when :text
  json.value data_attribute[:value].to_s
when :boolean
  json.value data_attribute[:value]
when :datetime
  json.value data_attribute[:value]
when :has_many_files
  json.value do
    json.partial! "api/documents/document", collection: data_attribute[:value], as: :document
  end
when :has_many_dossiers
  json.value do
    json.partial! "api/dossiers/dossier_list_item", collection: data_attribute[:value], as: :dossier
  end
when :has_one_dossier
  json.value do
    json.partial! "api/dossiers/dossier_list_item", dossier: data_attribute[:value]
  end
when :has_many_processes
  json.value do
    json.partial! "api/processes/list_item", collection: data_attribute[:value], as: :process
  end
else
  json.value data_attribute[:value]
end

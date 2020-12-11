json.array! @processes do |process|
  json.process do
    json.partial! "/api/processes/process_minimal", process: process
  end

  json.dossierFields process.data_entity.dossier_data_for_process do |data_attribute|
    unless (data_attribute[:type] == "has_one_dossier" && data_attribute[:value].nil?) ||
        (data_attribute[:type] == "has_many_dossiers" && data_attribute[:value].empty?)
      json.name data_attribute[:name]
      json.type data_attribute[:type]
      json.label data_attribute[:label]

      case (data_attribute[:type]).to_sym
      when :has_many_dossiers
        json.value do
          json.partial! "api/dossiers/dossier_list_item", collection: data_attribute[:value].reject(&:deleted?), as: :dossier
        end
      when :has_one_dossier
        json.value do
          json.partial! "api/dossiers/dossier_list_item", collection: [data_attribute[:value]].reject(&:deleted?), as: :dossier
        end
      end
    end
  end
end

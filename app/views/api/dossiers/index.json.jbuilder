json.dossier_definitions @dossier_definitions.map { |definition| {text: definition.label, value: definition.identifier} }
json.dossier_fields @dossier_fields

json.total_pages total_page_count_for(@result)
json.result do
  json.partial! "/api/dossiers/dossier_list_item", collection: @result, as: :dossier
end

json.definition do
  json.partial! "/api/dossier_definitions/dossier_definition_field", dossier_definition_field: data_field[:definition]
end
json.value data_field[:value]

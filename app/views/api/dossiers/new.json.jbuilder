json.dataFields do
  json.partial! "/api/dossiers/data_field", collection: @dossier.data_fields(true), as: :data_field
end

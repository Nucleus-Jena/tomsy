if dossier.nil?
  json.null!
else
  json.id dossier.id
  json.title dossier.title
  json.subtitle dossier.subtitle

  json.createdAt dossier.created_at

  json.dataFields do
    json.partial! "/api/dossiers/data_field", collection: dossier.data_fields, as: :data_field
  end

  json.definition do
    json.id dossier.definition.id
    json.label dossier.definition.label
  end
end

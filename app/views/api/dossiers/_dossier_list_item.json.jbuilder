if dossier.nil?
  json.null!
else
  json.id dossier.id
  json.definition_label dossier.definition.label
  json.deleted dossier.deleted?

  unless dossier.deleted?
    json.title dossier.title
    json.subtitle dossier.subtitle
  end
end

json.id document.id
json.type document.type
json.title document.title
json.updatedAt document.updated_at

if document.file?
  if document.file.attached?
    json.fileUrl rails_blob_url(document.file)
    json.fileName document.file.filename
    json.fileSize document.file.byte_size
  end
elsif document.link?
  json.linkUrl document.link_url
end

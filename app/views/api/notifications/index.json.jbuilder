json.counts do
  json.unmarked @counts[:unmarked]
  json.marked @counts[:marked]
end
json.elements do
  json.partial! "/api/notifications/notification", collection: @notifications, as: :notification
end

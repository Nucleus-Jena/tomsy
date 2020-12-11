json.id notification.id
json.event do
  json.partial! "api/activities/event", event: notification.event, withObject: true
end

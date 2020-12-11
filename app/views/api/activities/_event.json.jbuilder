json.id event.id
json.type event.action
json.objectType event.type
if local_assigns[:withObject]
  json.object do
    json.partial! "api/activities/data_item", data_item_value: event.object
  end
end
json.createdAt event.created_at

json.user do
  json.partial! "api/references/reference", object: event.subject
end

json.newValue do
  json.partial! "api/activities/data_item", data_item_value: event.new_value
end

json.oldValue do
  json.partial! "api/activities/data_item", data_item_value: event.old_value
end

json.mentioned event.mentioned_users.present? && event.mentioned_users.include?(current_user)

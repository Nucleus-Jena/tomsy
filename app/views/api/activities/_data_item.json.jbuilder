if data_item_value.nil?
  json.null!
else
  case data_item_value
  when User
    json.partial! "api/references/reference", object: data_item_value
  when Workflow::Process
    json.partial! "api/references/reference", object: data_item_value
  when Workflow::Task
    json.array!([data_item_value, data_item_value.process]) do |value|
      json.partial! "api/references/reference", object: value
    end
  when Ambition
    json.partial! "api/references/reference", object: data_item_value
  when Comment
    json.partial! "api/references/reference", object: data_item_value.object
  when Events::CommentCreatedEvent
    json.partial! "api/comments/comment", comment: data_item_value.comment, mentioned_users: data_item_value.mentioned_users
  when Date
    json.merge! I18n.l(data_item_value, format: :default)
  when String
    json.merge! data_item_value
  when TrueClass
    json.merge! "Ja"
  when FalseClass
    json.merge! "Nein"
  else
    json.nil!
  end
end

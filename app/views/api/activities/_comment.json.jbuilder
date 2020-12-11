json.id comment.id
json.message add_mention_labels(comment.message, current_user)
json.createdAt comment.created_at

json.author do
  json.reference do
    json.partial! "api/references/reference", object: comment.author
  end
  json.avatar do
    json.partial! "api/users/avatar", user: comment.author
  end
end

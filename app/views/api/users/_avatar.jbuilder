if user.nil?
  json.null!
else
  json.label user.avatar_label
  json.url user.avatar_url
end

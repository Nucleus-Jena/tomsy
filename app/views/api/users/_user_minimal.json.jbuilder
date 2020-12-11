if user.nil?
  json.null!
else
  json.id user.id
  json.firstname user.firstname
  json.lastname user.lastname
  json.email user.email
  json.avatarUrl user.avatar_url

  json.referenceLabel user.reference_label
  json.mentionLabel user.mention_label
end

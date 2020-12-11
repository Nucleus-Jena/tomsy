if user.nil?
  json.null!
else
  json.id user.id
  json.firstname user.firstname
  json.lastname user.lastname
  json.email user.email
  json.avatarUrl user.avatar_url

  json.abilities do
    json.rails_admin do
      json.abilities user.ability.permissions_for_subject("rails_admin")
    end
    json.camunda do
      json.abilities user.ability.permissions_for_subject("camunda")
    end
  end

  json.referenceLabel user.reference_label
end

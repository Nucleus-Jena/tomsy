json.id ambition.id
json.title ambition.title
json.description add_mention_labels(ambition.description, current_user)
json.closed ambition.closed
json.private ambition.private
json.stateUpdatedAt ambition.state_updated_at

json.assignee do
  json.partial! "api/users/user_minimal", user: ambition.assignee
end

json.contributors ambition.contributors, partial: "api/users/user_minimal", as: :user

json.processes ambition.processes, partial: "api/processes/process_minimal", as: :process

json.abilities current_user.ability.permissions_for_subject(ambition)

json.referenceLabel ambition.reference_label

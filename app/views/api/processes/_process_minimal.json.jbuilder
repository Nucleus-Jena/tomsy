if process.nil?
  json.null!
else
  json.id process.id
  json.assignee do
    json.partial! "api/users/user_minimal", user: process.assignee
  end

  if current_user.can?(:read, process)
    json.title process.title
    json.description add_mention_labels(process.description, current_user)
    json.state process.state
    json.stateUpdatedAt process.state_updated_at
    json.private process.private

    json.definition do
      json.name process.name
      json.key process.key
    end

    json.tasksDueCount process.due_tasks_count
    json.commentsCount process.comments.count

    json.referenceLabel process.reference_label
    json.mentionLabel process.mention_label
  else
    json.referenceLabel process.reference_label(true)
    json.noAccess true
  end
end

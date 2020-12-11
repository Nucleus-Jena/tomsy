if ambition.nil?
  json.null!
else
  json.id ambition.id
  json.assignee do
    json.partial! "api/users/user_minimal", user: ambition.assignee
  end

  if current_user.can?(:read, ambition)
    json.title ambition.title
    json.description add_mention_labels(ambition.description, current_user)
    json.closed ambition.closed
    json.private ambition.private
    json.stateUpdatedAt ambition.state_updated_at

    json.processAllCount ambition.processes.count
    json.processOpenCount ambition.running_processes(current_user).count

    json.commentsCount ambition.comments.count

    json.referenceLabel ambition.reference_label
    json.mentionLabel ambition.mention_label
  else
    json.referenceLabel ambition.reference_label(true)
    json.noAccess true
  end
end

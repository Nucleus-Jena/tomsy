if task.nil?
  json.null!
else
  json.id task.id
  json.assignee do
    json.partial! "api/users/user_minimal", user: task.assignee
  end

  json.process do
    json.id task.process.id

    if current_user.can?(:read, task.process)
      json.title task.process.title
      json.definition do
        json.name task.process.name
      end
      json.state task.process.state
    else
      json.noAccess true
    end
  end

  if current_user.can?(:read, task)
    json.description add_mention_labels(task.description, current_user)
    json.state task.state
    json.stateUpdatedAt task.state_updated_at
    json.dueAt task.due_at
    json.marked task.marked?(current_user)

    json.definition do
      json.partial! "api/tasks/definition", definition: task.task_definition
    end

    json.contributors task.contributors, partial: "api/users/user_minimal", as: :user

    json.commentsCount task.comments.count

    json.abilities current_user.ability.permissions_for_subject(task)

    json.referenceLabel task.reference_label
    json.mentionLabel task.mention_label
  else
    json.noAccess true
    json.referenceLabel task.reference_label(true)
  end
end

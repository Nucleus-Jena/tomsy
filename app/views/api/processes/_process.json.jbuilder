json.id process.id
json.title process.title
json.description add_mention_labels(process.description, current_user)
json.state process.state
json.stateUpdatedAt process.state_updated_at
json.private process.private

json.definition do
  json.id process.process_definition.id
  json.name process.name
  json.key process.key
end

json.assignee do
  json.partial! "api/users/user_minimal", user: process.assignee
end

json.contributors process.contributors, partial: "api/users/user_minimal", as: :user

json.tasks process.tasks.sort_by(&:order).select { |task| current_user.can?(:read, task) }, partial: "api/tasks/task_minimal", as: :task

json.ambitions process.ambitions.not_deleted.select { |ambition| current_user.can? :read, ambition },
  partial: "api/ambitions/ambition_minimal", as: :ambition

json.successorProcesses process.successor_processes.order(created_at: :desc), partial: "api/processes/process_minimal", as: :process
json.predecessorProcess do
  json.partial! "api/processes/process_minimal", process: process.predecessor_process
end

json.abilities current_user.ability.permissions_for_subject(process)

json.referenceLabel process.reference_label

json.tab_categories Workflow::Task.tab_categories_counts(@result)
  .map { |key, count| [key, key == "MARKED" ? @marked_count.total_count : count] }
  .map { |key, count| {text: t("task_tab_categories.#{key}"), value: key, count: count} }
json.users @users.map { |user| {text: user.name, value: user.id, avatar: user.avatar_url} }
json.process_definitions @process_definitions.map { |pd| {text: pd.name, value: pd.id} }
json.ambitions @ambitions.map { |a| {text: a.title, value: a.id} }
json.task_definitions @process_definitions.to_a.flat_map(&:task_definitions).map { |td| {text: td.name, value: td.id} }

json.total_pages total_page_count_for(@result)
json.result do
  json.partial! "/api/tasks/task_minimal", collection: @result, as: :task
end

json.tab_categories Workflow::Process.tab_categories_counts(@result).map { |key, count| {text: t("process_tab_categories.#{key}"), value: key, count: count} }
json.users @users.map { |user| {text: user.name, value: user.id, avatar: user.avatar_url} }
json.process_definitions @process_definitions.map { |pd| {text: pd.name, value: pd.id} }
json.ambitions @ambitions.map { |a| {text: a.title, value: a.id} }

json.total_pages total_page_count_for(@result)
json.result do
  json.partial! "/api/processes/process_minimal", collection: @result, as: :process
end

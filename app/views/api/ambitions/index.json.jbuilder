json.tab_categories Ambition.tab_categories_counts(@result).map { |key, count| {text: t("ambition_tab_categories.#{key}"), value: key, count: count} }
json.users @users.map { |user| {text: user.name, value: user.id, avatar: user.avatar_url} }
json.process_definitions @process_definitions.map { |pd| {text: pd.name, value: pd.id} }

json.total_pages total_page_count_for(@result)
json.result do
  json.partial! "/api/ambitions/ambition_minimal", collection: @result, as: :ambition
end

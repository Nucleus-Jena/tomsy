json.queryTerm @search_result.options[:term]
json.searchedWithMisspellingsDueToLowResultCount @search_result.options[:misspellings]
json.total_pages total_page_count_for(@search_result)
json.suggestion @search_result.suggestions.first

json.results do
  json.array! @search_result.with_highlights(multiple: true) do |result, highlights|
    case result.class.name
    when Ambition.name
      json.type "ambition"
      json.object do
        json.partial! "/api/ambitions/ambition_minimal", ambition: result
      end
    when Workflow::Task.name
      json.type "task"
      json.object do
        json.partial! "/api/tasks/task_minimal", task: result
      end
    when Workflow::Process.name
      json.type "process"
      json.object do
        json.partial! "/api/processes/process_minimal", process: result
      end
    when Dossier.name
      json.type "dossier"
      json.object do
        json.partial! "/api/dossiers/dossier_list_item", dossier: result
      end
    else
      json.error "Unknown result object with ruby-class #{result.class.name}!"
    end
    json.highlights do
      json.array! highlights.reject { |key, _fragments| key.in?([:title, :subtitle]) }.map do |highlight_key, highlight_fragments|
        if highlight_key.to_s.start_with?("data.")
          attribute_name = highlight_key.to_s.gsub(/^data\./, "")
          json.key result.data_entity.class.human_attribute_name(attribute_name)
        elsif highlight_key.to_s.start_with?("document__")
          _start, association_name, _doc_id, doc_attribute = highlight_key.to_s.split("__")
          json.key "#{result.data_entity.class.human_attribute_name(association_name)} - #{Document.human_attribute_name(doc_attribute)}"
        else
          json.key result.class.human_attribute_name(highlight_key)
        end
        json.fragments highlight_fragments.map { |fragment| sanitize(fragment, tags: ["mark"]) }
      end
    end
  end
end

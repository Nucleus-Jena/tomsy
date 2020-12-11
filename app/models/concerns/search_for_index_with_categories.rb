require "active_support/concern"

# Model may define class methods:
# REQUIRED:
#   def self.define_tab_categories
#     [["OPEN", ->(a) { !a.closed }],
#       ["CLOSED", ->(a) { a.closed }]
#   end
# OPTIONAL:
#   def self.defaults_for_search_for_index
#     {fields: ["title"], order: {title: :asc}}
#   end
module SearchForIndexWithCategories
  extend ActiveSupport::Concern

  included do
    def tab_categories
      self.class.define_tab_categories.map { |key, condition|
        key if condition.call(self)
      }.compact
    end

    private

    def all_who_can_as_ids(action, object)
      user_ids = []
      User.find_each do |user|
        user_ids << user.id if user.can?(action, object)
      end
      user_ids
    end
  end

  class_methods do
    def tab_categories_counts(search_result)
      buckets = search_result.aggs.dig("tab_categories", "buckets")
      define_tab_categories.map do |key, _condition|
        bucket_count = buckets.find { |a| a["key"] == key }.try(:[], "doc_count").to_i
        [key, bucket_count]
      end
    end

    def search_for_index(current_user, query = "*", aggregate = false, additional_query_params = {})
      default_params = {fields: [:title], match: :word_middle, misspellings: false}
      default_params.merge!(defaults_for_search_for_index) if defined?(defaults_for_search_for_index)
      query_params = default_params.merge(additional_query_params)

      # Enforce ACL
      query_params[:where] ||= {}
      query_params[:where][:acl_can_read] = current_user.id

      if aggregate
        query_params[:smart_aggs] = false
        query_params[:aggs] = {tab_categories: {
          where: query_params[:where].except(:tab_categories, :marked_by_user_ids) # Our tabs should always show the same count even thus we exclude tab filters here
        }}
      end

      search(query, query_params)
    end

    def search_for_list(current_user, query = "*", additional_query_params = {})
      query_params = {fields: ["identifier^3", "title^2", "subtitle"], limit: 10}
      search_for_index(current_user, query, false, query_params.merge(additional_query_params))
    end
  end
end

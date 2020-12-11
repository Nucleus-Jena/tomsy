module PaginationHelper
  def total_page_count_for(searchkick_result)
    (searchkick_result.total_count + searchkick_result.per_page - 1) / searchkick_result.per_page
  end
end

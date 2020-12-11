require "test_helper"
require "minitest/mock"

class PaginationHelperTest < ActionView::TestCase
  test "#total_page_count_for should calculate right results" do
    expectations = [
      [100, 25, 4],
      [99, 25, 4],
      [101, 25, 5]
    ]
    expectations.each do |results, per_page, total_pages|
      result = MiniTest::Mock.new
      result.expect(:total_count, results)
      result.expect(:per_page, per_page)
      result.expect(:per_page, per_page)
      assert_equal total_pages, total_page_count_for(result)
    end
  end

  test "#total_page_count_for should work with searchkick result" do
    Ambition.reindex
    all_results_fit_on_one_page = Ambition.search("*", per_page: Ambition.count + 1)
    assert_nothing_raised do
      assert_equal 1, total_page_count_for(all_results_fit_on_one_page)
    end
  end
end

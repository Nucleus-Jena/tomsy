class Api::SearchController < ApiController
  def fulltext
    page = params[:page]&.to_i || 1
    @search_result = Search.new(current_user).fulltext(params[:query], {page: page})
  end
end

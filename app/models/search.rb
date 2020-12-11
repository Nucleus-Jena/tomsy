class Search
  attr_accessor :user
  def initialize(user = nil)
    @user = user
  end

  def fulltext(query = nil, additional_options = {})
    query = "*" if query.blank?

    search_options = {
      index_name: [Workflow::Task, Workflow::Process, Ambition, Dossier],
      fields: ["title^3", "*"],
      highlight: {tag: "<mark>", fragment_size: 200},
      page: 1, per_page: 10,
      suggest: [:title, :subtitle],
      misspellings: {below: 3} # only use approximate search if not enough results were found
    }.merge(additional_options)
    # Apply ACL if user is provided
    search_options[:where] = {acl_can_read: user.id} if user

    Searchkick.search(query, search_options)
  end
end

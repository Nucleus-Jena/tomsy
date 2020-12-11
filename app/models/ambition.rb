class Ambition < ApplicationRecord
  include AclSearchSupport
  include SearchForIndexWithCategories

  belongs_to :assignee, class_name: "User", optional: true
  has_and_belongs_to_many :contributors, class_name: "User", after_add: :reindex_later, after_remove: :reindex_later
  has_and_belongs_to_many :processes, class_name: "Workflow::Process", association_foreign_key: :workflow_process_id,
                                      after_add: :reindex_processes_and_self, after_remove: :reindex_processes_and_self

  has_many :comments, as: :object, dependent: :destroy

  scope :not_deleted, -> { where(deleted: false) }

  validates :title, presence: true, length: {maximum: 80}

  searchkick language: "german", callbacks: :async, word_middle: [:identifier, :title, :subtitle], suggest: [:title, :subtitle]
  scope :search_import, -> { not_deleted }

  after_save :reindex_processes_and_self

  def running_processes(user = nil)
    result = processes.select(&:running?)
    result = result.select { |process| user.can?(:read, process) } if user
    result
  end

  def self.define_tab_categories
    [["OPEN", ->(a) { !a.closed }],
      ["SOME_PROCESSES_RUNNING", ->(a) { !a.closed && a.running_processes.any? }],
      ["CLOSED", ->(a) { a.closed }],
      ["PRIVATE", ->(a) { a.private }],
      ["ALL", ->(_a) { true }]]
  end

  def self.defaults_for_search_for_index
    {order: {title: :asc}}
  end

  def search_data
    {
      identifier: [identifier, id.to_s],
      title: title,
      subtitle: nil,
      description: description,
      created_at: created_at,
      comments: comments.map(&:message),
      tab_categories: tab_categories,
      assignee_id: assignee_id,
      contributor_ids: contributors.map(&:id),
      process_definition_ids: processes.map(&:process_definition).uniq.map(&:id)
    }.merge(acl_search_restrictions)
  end

  def should_index?
    !deleted
  end

  def processes=(new_processes)
    removed_processes = processes - new_processes
    super(new_processes)
    reindex_processes_and_self([removed_processes + new_processes].uniq)
  end

  def identifier
    "!#{id}"
  end

  def reference_label(noaccess = false)
    identifier + (noaccess || deleted? ? "" : " • #{title}")
  end

  def mention_label(noaccess = false)
    reference_label(noaccess)
  end

  private

  def reindex_later(_params)
    reindex
  end

  def reindex_processes_and_self(process = nil)
    if process.is_a?(Workflow::Process) # called by habtm association
      process.reindex
    else
      processes.find_each(&:reindex)
    end
    reindex
  end
end

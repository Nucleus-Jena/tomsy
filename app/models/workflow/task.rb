class Workflow::Task < ApplicationRecord
  include AclSearchSupport
  include SearchForIndexWithCategories

  after_commit :broadcast_user_info_changes, on: :update
  after_save :reindex_self_and_process, if: :saved_change_to_state?

  belongs_to :process, foreign_key: "workflow_process_id"
  belongs_to :task_definition, class_name: "Workflow::TaskDefinition", foreign_key: "workflow_task_definition_id", inverse_of: :tasks

  delegate :key, :order, :name, to: :task_definition
  alias title name

  belongs_to :assignee, class_name: "User", optional: true
  has_and_belongs_to_many :contributors, class_name: "User", foreign_key: :workflow_task_id, after_add: :reindex_self_and_process, after_remove: :reindex_self_and_process

  has_and_belongs_to_many :marked_by_users, class_name: "User", foreign_key: :workflow_task_id, join_table: :users_workflow_tasks_marked, after_add: :reindex_self, after_remove: :reindex_self

  has_many :comments, as: :object, dependent: :destroy

  validates :state, :process, :task_definition, presence: true

  scope :created, -> { where(state: CREATED) }
  scope :started, -> { where(state: STARTED) }
  scope :completed, -> { where(state: COMPLETED) }
  scope :deleted, -> { where(state: DELETED) }
  scope :open, -> { where(state: STARTED) }
  scope :closed, -> { where(state: COMPLETED).or(where(state: DELETED)) }
  scope :assigned_to, ->(user) { where(assignee: user) }
  scope :with_due_in_past, -> { where("due_at < ?", Date.today) }

  searchkick language: "german", callbacks: :async, word_middle: [:identifier, :title, :subtitle], suggest: [:title, :subtitle]

  CREATED = "created"
  STARTED = "started"
  COMPLETED = "completed"
  DELETED = "deleted"

  TASK_STATES = [CREATED, STARTED, COMPLETED, DELETED]

  def state=(new_state)
    raise "Allowed state values: #{TASK_STATES}" unless new_state.in? TASK_STATES
    write_attribute(:state, new_state)
  end

  def description=(new_description)
    new_description = nil if new_description == task_definition.description
    write_attribute(:description, new_description)
  end

  def description
    read_attribute(:description).nil? ? task_definition.description : read_attribute(:description)
  end

  def data_attributes(user)
    process.data_entity.data_for_task(key, user)
  end

  def data_changes
    data_entity_class = process.data_entity.class
    all_attributes = data_entity_class.task_attributes(key)
    all_attributes.flat_map { |attribute|
      DataChange.who_changed_them_all(process.data_entity, attribute).map do |who_changed_id, last_change|
        next unless last_change

        Events::DataChangedEvent.create(
          subject: User.find_by(id: who_changed_id),
          object: self,
          data: {attribute_name: data_entity_class.human_attribute_name(attribute)},
          created_at: last_change.created_at
        )
      end
    }.compact.sort_by(&:created_at)
  end

  def events_with_data_changes
    (Event.where(object: self) + data_changes).sort_by(&:created_at)
  end

  def update_from_camunda_task!(camunda_task)
    events = []

    self.camunda_id ||= camunda_task.id
    self.created_at = camunda_task.startTime && Time.zone.parse(camunda_task.startTime) # TODO: Add started_at column
    self.ended_at ||= camunda_task.endTime && Time.zone.parse(camunda_task.endTime)
    self.due_at ||= camunda_task.due && Time.zone.parse(camunda_task.due)
    unless state == COMPLETED
      self.state = get_state_from_camunda_task(camunda_task)
      self.state_updated_at = Time.now
    end

    save!

    if state_previously_changed?
      case state
      when DELETED
        events << Events::TaskCanceledEvent.new(object: self)
      when STARTED
        events << Events::TaskStartedEvent.new(object: self)
      end
    end

    events
  end

  def marked?(user)
    marked_by_users.exists?(user.id)
  end

  def completable?(task_result)
    return true unless gate?
    return true if task_result.values.none?(&:nil?)

    errors.add(:base, "Aufgabe kann erst abgeschlossen werden, wenn Daten vollständig eingegeben sind.")
    false
  end

  def gate?
    process.data_entity.get_task_result(key).is_a?(Hash)
  end

  def complete
    events = []

    task_result = process.data_entity.get_task_result(key)
    return false unless completable?(task_result)

    post_body = nil
    post_body = {"variables": task_result.map { |k, v| [k, {"value" => v}] }.to_h} unless task_result.nil?

    begin
      Camunda::Task.post("#{self.camunda_id}/complete", {}, post_body&.to_json)
    rescue ActiveResource::ServerError => e
      puts e.response.body
      raise e
    end
    events += process.update_tasks_from_camunda

    [true, events]
  end

  def created?
    state == CREATED
  end

  def started?
    state == STARTED
  end

  def completed?
    state == COMPLETED
  end

  def deleted?
    state == DELETED
  end

  def open?
    created? || started?
  end

  def closed?
    completed? || deleted?
  end

  def due?
    self.due_at.present? && self.due_at < Date.today
  end

  def private
    process.private
  end

  def contributors=(new_contributors)
    super(new_contributors)
    reindex_self_and_process
  end

  def marked_by_users=(new_users)
    super(new_users)
    reindex_self
  end

  def assignee=(new_assignee)
    super(new_assignee)
    reindex_self_and_process
  end

  def self.define_tab_categories
    [["STARTED", ->(t) { t.started? }],
      ["MARKED", ->(_t) { true }], # Same as ALL as this is no category valid for all users (counts are user specific)
      ["COMPLETED", ->(t) { t.completed? }],
      ["DUE", ->(t) { t.open? && t.due? }],
      ["PRIVATE", ->(t) { t.private }],
      ["ALL", ->(_t) { true }]]
  end

  def self.marked_count_query(user, query_params)
    query_params = query_params.deep_dup
    query_params[:where][:marked_by_user_ids] = user.id
    query_params[:where][:tab_categories] = "MARKED"
    query_params[:execute] = false
    Workflow::Task.search_for_index(user, "*", false, query_params)
  end

  def identifier
    "##{id}"
  end

  def reference_label(noaccess = false)
    identifier + (noaccess ? "" : " • #{title}")
  end

  def mention_label(noaccess = false)
    reference_label(noaccess)
  end

  private

  def search_data
    {
      id_sort: id.to_s.rjust(8, "0"),
      created_at: created_at,
      identifier: [identifier, id.to_s],
      title: title,
      subtitle: "#{process.name} > #{process.title}",
      description: read_attribute(:description), # only index custom descriptions
      comments: comments.map(&:message),
      tab_categories: tab_categories,
      assignee_id: assignee_id,
      contributor_ids: contributors.map(&:id),
      process_definition_id: process.process_definition.id,
      ambition_ids: process.ambitions.not_deleted.map(&:id),
      task_definition_id: task_definition.id,
      marked_by_user_ids: marked_by_user_ids
    }.merge(acl_search_restrictions)
  end

  def reindex_self(_params = nil)
    reindex
  end

  def reindex_self_and_process(_params = nil)
    reindex
    process.reindex
  end

  def get_state_from_camunda_task(camunda_task)
    case camunda_task.deleteReason
    when DELETED
      DELETED
    when COMPLETED
      COMPLETED
    else
      STARTED
    end
  end

  def broadcast_user_info_changes
    if previous_changes.key?(:state) || previous_changes.key?(:due_at) || previous_changes.key?(:assignee_id)
      UserChannel.broadcast_info(assignee) unless assignee.nil?

      if previous_changes.key?(:assignee_id)
        old_assignee = User.find_by(id: previous_changes[:assignee_id].first)
        UserChannel.broadcast_info(old_assignee) unless old_assignee.nil?
      end
    end
  end
end

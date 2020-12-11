class Workflow::Process < ApplicationRecord
  include AclSearchSupport
  include SearchForIndexWithCategories

  has_many :tasks, foreign_key: "workflow_process_id", dependent: :destroy

  belongs_to :process_definition, class_name: "Workflow::ProcessDefinition", foreign_key: "workflow_process_definition_id"
  belongs_to :data_entity, polymorphic: true, dependent: :destroy

  def data_entity_with_class_loading
    # puts "DATA ENTITY WITH CLASS LOADING"
    process_definition.model_class # needs to be accessed once
    data_entity_without_class_loading
  end

  alias data_entity_without_class_loading data_entity
  alias data_entity data_entity_with_class_loading

  has_and_belongs_to_many :ambitions, foreign_key: :workflow_process_id, after_add: :reindex_ambition_and_self, after_remove: :reindex_ambition_and_self

  belongs_to :assignee, class_name: "User", optional: true
  has_and_belongs_to_many :contributors, class_name: "User", foreign_key: :workflow_process_id, after_add: :reindex_tasks_and_self, after_remove: :reindex_tasks_and_self
  belongs_to :cancel_user, class_name: "User", foreign_key: "cancel_user_id", optional: true

  belongs_to :predecessor_process, class_name: "Workflow::Process", optional: true
  has_many :successor_processes, class_name: "Workflow::Process", foreign_key: "predecessor_process_id", dependent: :nullify

  has_many :comments, as: :object, dependent: :destroy

  validates :state, presence: true
  validates_presence_of :title, on: :update

  after_save :reindex_tasks_and_self
  after_destroy :cleanup_invalid_data
  after_destroy_commit :delete_camunda_process_instance

  searchkick language: "german", callbacks: :async, word_middle: [:identifier, :title, :subtitle], suggest: [:title, :subtitle]

  RUNNING = "running"
  COMPLETED = "completed"
  CANCELED = "canceled"

  PROCESS_STATES = [RUNNING, COMPLETED, CANCELED]

  delegate :key, :name, to: :process_definition

  def description=(new_description)
    new_description = nil if new_description == process_definition.description
    write_attribute(:description, new_description)
  end

  def description
    read_attribute(:description).nil? ? process_definition.description : read_attribute(:description)
  end

  def self.create_from_definition(process_definition)
    events = []

    process = Workflow::Process.new
    process.process_definition = process_definition
    process.data_entity = process_definition.data_entity_class.create!
    process.state = Workflow::Process::RUNNING

    # Start new process in camunda and link it with our newly created object
    response = Camunda::ProcessDefinition.post("key/#{process.key}/start")
    camunda_process_instance = JSON.parse(response.body)
    process.camunda_id = camunda_process_instance["id"]

    if process.save!
      process.update!(title: "#{process_definition.label_prefix}-#{process.id}") # set default title

      process_definition.task_definitions.map do |task_definition|
        task = Workflow::Task.create!(process: process,
                                      state: Workflow::Task::CREATED,
                                      task_definition: task_definition)

        events << Events::TaskCreatedEvent.new(object: task)
      end
    end

    events.concat(process.update_tasks_from_camunda)

    [process, events]
  end

  def update_tasks_from_camunda
    events = []

    Camunda::History::Task.where(processInstanceId: camunda_id).each do |camunda_task|
      task = tasks.all.find { |t| t.key == camunda_task.taskDefinitionKey }
      events += task.update_from_camunda_task!(camunda_task)
    end

    if running? && tasks.started.none?
      update!(state: COMPLETED, state_updated_at: Time.now, ended_at: Time.now)

      events << Events::ProcessCompletedEvent.new(object: self)
      ambitions.not_deleted.each do |ambition|
        events << Events::AmbitionCompletedProcessEvent.new(object: ambition, data: {completed_process: self})
      end
    end

    events
  end

  def delete_camunda_process_instance
    Camunda::ProcessInstance.find(camunda_id).destroy
  rescue ActiveResource::ResourceNotFound
    Raven.capture_message("Camunda process instance not found", extra: {camunda_process_id: camunda_id})
  end

  def cancel(cancel_info, cancel_user)
    return false unless running?

    delete_camunda_process_instance

    if update(state: CANCELED, state_updated_at: Time.now, ended_at: Time.now, cancel_info: cancel_info, cancel_user: cancel_user)
      return [true, update_tasks_from_camunda]
    end

    false
  end

  def running?
    state == RUNNING
  end

  def completed?
    state == COMPLETED
  end

  def canceled?
    state == CANCELED
  end

  def due_tasks_count
    return 0 unless running?

    tasks.count { |task| task.due? && task.open? }
  end

  def self.define_tab_categories
    [["RUNNING", ->(p) { p.running? }],
      ["WITH_DUE_TASKS", ->(p) { !p.completed? && p.due_tasks_count > 0 }],
      ["COMPLETED", ->(p) { p.completed? }],
      ["PRIVATE", ->(p) { p.private }],
      ["ALL", ->(_p) { true }]]
  end

  def ambitions=(ambitions)
    super(ambitions)
    ambitions.each { |a| a.reindex }
  end

  def contributors=(new_contributors)
    super(new_contributors)
    reindex_tasks_and_self
  end

  def identifier
    "%#{id}"
  end

  def reference_label(noaccess = false)
    identifier + (noaccess ? "" : " • #{title}")
  end

  def mention_label(noaccess = false)
    reference_label(noaccess)
  end

  private

  def cleanup_invalid_data
    Event.destroy_invalid
    Document.destroy_invalid
  end

  def search_data
    {
      id_sort: id.to_s.rjust(8, "0"),
      identifier: [identifier, id.to_s],
      title: title,
      subtitle: name,
      cancel_info: cancel_info,
      description: read_attribute(:description), # only custom description
      comments: comments.map(&:message),
      ambitions: ambitions.not_deleted.where(private: false).map(&:title),
      ambition_ids: ambitions.not_deleted.map(&:id),
      tab_categories: tab_categories,
      assignee_id: assignee_id,
      contributor_ids: contributors.map(&:id),
      process_definition_ids: process_definition.id
    }.merge(data_entity.search_defaults_for_data_entities).merge(acl_search_restrictions)
  end

  def reindex_tasks_and_self(_params = nil)
    reindex
    tasks.all.each(&:reindex)
  end

  def reindex_ambition_and_self(ambition)
    ambition.reindex

    reindex
  end
end

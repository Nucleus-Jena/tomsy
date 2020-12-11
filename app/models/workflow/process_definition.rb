class Workflow::ProcessDefinition < ApplicationRecord
  include AclSearchSupport
  has_many :processes, foreign_key: "workflow_process_definition_id", dependent: :destroy
  has_many :task_definitions, foreign_key: "workflow_process_definition_id", dependent: :destroy
  has_many :FlowObjectDefinition, foreign_key: "workflow_process_definition_id", dependent: :destroy

  has_and_belongs_to_many :groups, foreign_key: :workflow_process_definition_id

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :label_prefix, presence: true, uniqueness: true
  validates_length_of :label_prefix, within: 2..4
  validates_format_of :label_prefix, with: /\A[A-Z]*\z/, message: "darf nur aus Großbuchstaben bestehen"

  store_accessor :model, :model_class, suffix: "name"

  searchkick language: "german", callbacks: :async, word_middle: [:name, :description], suggest: [:title, :subtitle]

  def model_class
    return nil if model_class_name.blank?
    ProcessDataEntity.get_specific_model(model_class_name)
  end

  def data_entity_class
    model_class
  end

  before_save do
    model&.compact
  end

  def self.search_for_index(current_user, query = "*", additional_query_params = {})
    search(query, {fields: ["name"], match: :word_middle, misspellings: false,
                   where: {acl_can_read: current_user.id},
                   order: {name: :asc}}.merge(additional_query_params))
  end

  def search_data
    {
      name: name,
      description: description
    }.merge({acl_can_read: all_who_can_as_ids(:create, processes.new)})
  end
end

class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, through: :user_groups, dependent: :destroy

  has_and_belongs_to_many :process_definitions, class_name: "Workflow::ProcessDefinition", association_foreign_key: :workflow_process_definition_id, after_add: :full_reindex, after_remove: :full_reindex

  validates :name, presence: true, uniqueness: true

  private

  def full_reindex(_params)
    RunFullReindexJob.perform_later
  end
end

class User < ApplicationRecord
  has_one_attached :avatar
  attr_accessor :remove_avatar
  after_save { avatar.purge if remove_avatar == "1" }

  has_many :user_groups
  has_many :groups, through: :user_groups, dependent: :destroy

  has_many :assigned_processes, class_name: "Workflow::Process", foreign_key: "assignee_id", dependent: :nullify
  has_many :canceled_processes, class_name: "Workflow::Process", foreign_key: "cancel_user_id", dependent: :nullify
  has_many :assigned_tasks, class_name: "Workflow::Task", foreign_key: "assignee_id", dependent: :nullify
  has_many :assigned_ambitions, class_name: "Ambition", foreign_key: "assignee_id", dependent: :nullify
  has_and_belongs_to_many :contributed_tasks, class_name: "Workflow::Task", association_foreign_key: :workflow_task_id
  has_and_belongs_to_many :marked_tasks, class_name: "Workflow::Task", association_foreign_key: :workflow_task_id, join_table: :users_workflow_tasks_marked
  has_and_belongs_to_many :contributed_processes, class_name: "Workflow::Process", association_foreign_key: :workflow_process_id
  has_and_belongs_to_many :contributed_ambitions, class_name: "Ambition"

  has_many :events, foreign_key: "subject_id", dependent: :nullify
  has_many :notifications, dependent: :destroy

  has_many :comments, foreign_key: "author_id", dependent: :destroy

  has_many :dossiers, foreign_key: "created_by_id", dependent: :nullify

  validates :firstname, :lastname, presence: true
  validates :email, presence: true, uniqueness: true

  scope :order_by_name_with_user_first, ->(user) { order(Arel.sql("(id = #{user.id}) desc")).order(:firstname, :lastname) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, # basic authentication support for hashed password in users table
    :timeoutable, # timouts session after configure period. Without this user is NEVER signed out by default (even if "remember me" is NOT checked)
    :rememberable # makes session cookie expire after 14 days if "remember me" is checked on login.

  delegate :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
  end

  def is_admin?
    in_group?(Group.find_by!(name: "admin"))
  end

  def in_group?(group)
    groups.to_a.include?(group)
  end

  def name
    "#{firstname} #{lastname}"
  end

  def identifier
    "@#{id}"
  end

  def reference_label(noaccess = false)
    "#{firstname} #{lastname}"
  end

  def mention_label(noaccess = false)
    "@#{name}"
  end

  def avatar_label
    "#{firstname[0]}#{lastname[0]}"
  end

  def avatar_url
    return nil unless avatar.attached?
    Rails.application.routes.url_helpers.rails_representation_url(avatar.variant(resize_to_fit: [36, 36]), only_path: true)
  end
end

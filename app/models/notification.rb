class Notification < ApplicationRecord
  after_commit :broadcast_user_info_changes, on: [:create, :update]

  belongs_to :user
  belongs_to :event

  scope :marked, -> { where.not(marked_at: nil) }
  scope :unmarked, -> { where(marked_at: nil) }

  validates :user, :event, presence: true
  validates :event, uniqueness: {scope: :user}

  def type
    event.class.name.demodulize.underscore.sub(/_event\Z/, "")
  end

  def partial
    "#{event.class.name.demodulize.underscore}.html.haml"
  end

  def marked?
    !marked_at.nil?
  end

  def receiver_is_originator?
    event.subject == user
  end

  def receiver_is_involved?
    event.involved_user == user
  end

  def receiver_role
    "#{"not_" unless receiver_is_originator?}originator_and_#{"not_" unless receiver_is_involved?}involved".to_sym
  end

  private

  def broadcast_user_info_changes
    UserChannel.broadcast_info(user)
  end
end

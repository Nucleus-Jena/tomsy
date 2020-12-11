class Events::CommentCreatedEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def comment
    object
  end

  def mentioned_users
    data&.[](:mentioned_users)
  end

  def notification_receivers
    (comment.object.contributors | mentioned_users) - [subject]
  end

  def new_value
    self
  end

  def action
    "commented"
  end

  def type
    comment.object.class.name.demodulize.camelize(:lower)
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be a comment") unless comment.is_a?(Comment)
    errors.add(:data, "value for key :mentioned_users should be an array of users") unless mentioned_users.all? { |u| u.is_a?(User) }
  end
end

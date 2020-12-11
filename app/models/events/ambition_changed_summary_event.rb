class Events::AmbitionChangedSummaryEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def ambition
    object
  end

  def mentioned_users
    data&.[](:mentioned_users)
  end

  def new_summary
    data&.[](:new_summary)
  end

  def old_summary
    data&.[](:old_summary)
  end

  def notification_receivers
    (ambition.contributors | mentioned_users) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an ambition") unless ambition.is_a?(Ambition)
    errors.add(:data, "value for key :new_summary should be a string") unless new_summary.is_a?(String)
    errors.add(:data, "value for key :old_summary should be a string") unless old_summary.nil? || old_summary.is_a?(String)
    errors.add(:data, "value for key :mentioned_users should be an array of users") unless mentioned_users.all? { |u| u.is_a?(User) }
  end
end

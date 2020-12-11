class Events::AmbitionUnassignedEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def ambition
    object
  end

  def old_assignee
    data&.[](:old_assignee)
  end

  alias old_value old_assignee

  def notification_receivers
    (ambition.contributors | [old_assignee].compact) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an ambition") unless ambition.is_a?(Ambition)
    errors.add(:data, "value for key :old_assignee should be a user") unless old_assignee.is_a?(User)
  end
end

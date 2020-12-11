class Events::ProcessUnassignedEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def process
    object
  end

  def old_assignee
    data&.[](:old_assignee)
  end

  alias involved_user old_assignee

  alias old_value old_assignee

  def notification_receivers
    (process.contributors | process.tasks.map(&:assignee).compact | [old_assignee].compact) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be a process") unless process.is_a?(Workflow::Process)
    errors.add(:data, "value for key :old_assignee should be a user") unless old_assignee.is_a?(User)
  end
end

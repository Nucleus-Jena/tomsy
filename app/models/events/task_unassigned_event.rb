class Events::TaskUnassignedEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def task
    object
  end

  def old_assignee
    data&.[](:old_assignee)
  end

  alias involved_user old_assignee

  alias old_value old_assignee

  def notification_receivers
    (task.contributors | [task.process.assignee].compact | [old_assignee].compact) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be a task") unless task.is_a?(Workflow::Task)
    errors.add(:data, "value for key :old_assignee should be a user") unless old_assignee.is_a?(User)
  end
end

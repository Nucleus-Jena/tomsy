class Events::TaskAssignedEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def task
    object
  end

  def new_assignee
    data&.[](:new_assignee)
  end

  def old_assignee
    data&.[](:old_assignee)
  end

  alias new_value new_assignee
  alias old_value old_assignee

  def notification_receivers
    (task.contributors | [task.process.assignee].compact | [task.assignee].compact | [old_assignee].compact) - [subject]
  end

  alias involved_user new_assignee

  private

  def validate_event_type_values
    errors.add(:object, "should be a task") unless task.is_a?(Workflow::Task)
    errors.add(:data, "value for key :new_assignee should be a user") unless new_assignee.is_a?(User)
    errors.add(:data, "value for key :old_assignee should be a user") unless old_assignee.nil? || old_assignee.is_a?(User)
  end
end

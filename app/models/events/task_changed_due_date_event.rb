class Events::TaskChangedDueDateEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def task
    object
  end

  def new_due_date
    data&.[](:new_due_date)
  end

  def old_due_date
    data&.[](:old_due_date)
  end

  alias new_value new_due_date
  alias old_value old_due_date

  def notification_receivers
    (task.contributors | [task.process.assignee].compact) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be a task") unless task.is_a?(Workflow::Task)
    errors.add(:data, "value for key :new_due_date should be a date") unless new_due_date.nil? || new_due_date.is_a?(Date)
    errors.add(:data, "value for key :old_due_date should be a date") unless old_due_date.nil? || old_due_date.is_a?(Date)
  end
end

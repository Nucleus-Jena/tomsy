class Events::TaskCanceledEvent < Event
  validate :validate_event_type_values

  def task
    object
  end

  def notification_receivers
    [task.assignee].compact
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be a task") unless task.is_a?(Workflow::Task)
  end
end

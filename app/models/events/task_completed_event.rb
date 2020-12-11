class Events::TaskCompletedEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def task
    object
  end

  def notification_receivers
    (task.contributors | task.process.contributors) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be a task") unless task.is_a?(Workflow::Task)
  end
end

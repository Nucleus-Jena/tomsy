class Events::ProcessCompletedEvent < Event
  validate :validate_event_type_values

  def process
    object
  end

  def notification_receivers
    process.contributors
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be a process") unless process.is_a?(Workflow::Process)
  end
end

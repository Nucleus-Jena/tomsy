class Events::AmbitionCompletedProcessEvent < Event
  validate :validate_event_type_values

  def ambition
    object
  end

  def completed_process
    data&.[](:completed_process)
  end

  alias old_value completed_process

  def notification_receivers
    ambition.contributors - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an ambition") unless ambition.is_a?(Ambition)
    errors.add(:data, "value for key :completed_process should be a process") unless completed_process.is_a?(Workflow::Process)
  end
end

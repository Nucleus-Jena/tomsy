class Events::AmbitionRemovedProcessEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def ambition
    object
  end

  def removed_process
    data&.[](:removed_process)
  end

  alias old_value removed_process

  def notification_receivers
    (ambition.contributors | removed_process.contributors.reject { |user| user.cannot?(:read, ambition) }) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an ambition") unless ambition.is_a?(Ambition)
    errors.add(:data, "value for key :removed_process should be a process") unless removed_process.is_a?(Workflow::Process)
  end
end

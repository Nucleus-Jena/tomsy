class Events::AmbitionAddedProcessEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def ambition
    object
  end

  def added_process
    data&.[](:added_process)
  end

  alias new_value added_process

  def notification_receivers
    (ambition.contributors | added_process.contributors.reject { |user| user.cannot?(:read, ambition) }) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an ambition") unless ambition.is_a?(Ambition)
    errors.add(:data, "value for key :added_process should be a process") unless added_process.is_a?(Workflow::Process)
  end
end

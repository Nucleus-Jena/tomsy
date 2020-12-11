class Events::ProcessAddedSuccessorProcessEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def process
    object
  end

  def successor_process
    data&.[](:successor_process)
  end

  alias new_value successor_process

  private

  def validate_event_type_values
    errors.add(:object, "should be a process") unless process.is_a?(Workflow::Process)
    errors.add(:data, "value for key :successor_process should be a process") unless successor_process.is_a?(Workflow::Process)
  end
end

class Events::DataChangedEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def task
    object
  end

  def attribute_name
    data&.[](:attribute_name)
  end

  def message
    "#{attribute_name} bearbeitet"
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be a task") unless task.is_a?(Workflow::Task)
    errors.add(:data, "value for key :attribute_name should be a string") unless attribute_name.is_a?(String)
  end
end

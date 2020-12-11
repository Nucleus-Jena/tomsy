class Events::ProcessChangedVisibilityEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def process
    object
  end

  def new_visibility
    data&.[](:new_visibility)
  end

  alias new_value new_visibility

  def notification_receivers
    process.contributors - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be a process") unless process.is_a?(Workflow::Process)
    errors.add(:data, "value for key :new_visibility should be a boolean") unless new_visibility.is_a?(TrueClass) || new_visibility.is_a?(FalseClass)
  end
end

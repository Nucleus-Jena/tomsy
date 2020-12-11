class Events::AmbitionChangedVisibilityEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def ambition
    object
  end

  def new_visibility
    data&.[](:new_visibility)
  end

  alias new_value new_visibility

  def notification_receivers
    ambition.contributors - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an ambition") unless ambition.is_a?(Ambition)
    errors.add(:data, "value for key :new_visibility should be a boolean") unless new_visibility.is_a?(TrueClass) || new_visibility.is_a?(FalseClass)
  end
end

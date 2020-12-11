class Events::AmbitionChangedTitleEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def ambition
    object
  end

  def new_title
    data&.[](:new_title)
  end

  def old_title
    data&.[](:old_title)
  end

  alias new_value new_title
  alias old_value old_title

  def notification_receivers
    ambition.contributors - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an ambition") unless ambition.is_a?(Ambition)
    errors.add(:data, "value for key :new_title should be a string") unless new_title.is_a?(String)
    errors.add(:data, "value for key :old_title should be a string") unless old_title.nil? || old_title.is_a?(String)
  end
end

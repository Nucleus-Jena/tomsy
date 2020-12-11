class Events::AmbitionRemovedContributorEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def ambition
    object
  end

  def removed_contributor
    data&.[](:removed_contributor)
  end

  alias involved_user removed_contributor

  alias old_value removed_contributor

  def notification_receivers
    ([ambition.assignee].compact | [removed_contributor]) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an ambition") unless ambition.is_a?(Ambition)
    errors.add(:data, "value for key :removed_contributor should be a user") unless removed_contributor.is_a?(User)
  end
end

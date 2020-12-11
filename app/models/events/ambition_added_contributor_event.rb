class Events::AmbitionAddedContributorEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def ambition
    object
  end

  def added_contributor
    data&.[](:added_contributor)
  end

  alias involved_user added_contributor

  alias new_value added_contributor

  def notification_receivers
    ([ambition.assignee].compact | [added_contributor]) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an ambition") unless ambition.is_a?(Ambition)
    errors.add(:data, "value for key :added_contributor should be a user") unless added_contributor.is_a?(User)
  end
end

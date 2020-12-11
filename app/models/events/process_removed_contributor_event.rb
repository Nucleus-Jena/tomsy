class Events::ProcessRemovedContributorEvent < Event
  validate :validate_event_type_values

  validates :subject, presence: true

  def process
    object
  end

  def removed_contributor
    data&.[](:removed_contributor)
  end

  alias involved_user removed_contributor

  alias old_value removed_contributor

  def notification_receivers
    ([process.assignee].compact | [removed_contributor]) - [subject]
  end

  private

  def validate_event_type_values
    errors.add(:object, "should be an process") unless process.is_a?(Workflow::Process)
    errors.add(:data, "value for key :removed_contributor should be a user") unless removed_contributor.is_a?(User)
  end
end

class Event < ApplicationRecord
  after_commit :dispatch_event, on: :create

  belongs_to :object, polymorphic: true
  belongs_to :subject, class_name: "User", optional: true
  has_many :notifications, dependent: :destroy

  serialize :data, GlobalIdSerializer

  validate :validate_data

  def involved_user
    nil
  end

  def new_value
    nil
  end

  def old_value
    nil
  end

  def mentioned_users
    []
  end

  def action
    self.class.name.demodulize.sub(/\A(Ambition|Task|Process|Comment)/, "").sub(/Event\Z/, "").camelize(:lower)
  end

  def type
    object.class.name.demodulize.camelize(:lower)
  end

  def self.destroy_invalid
    all.find_each do |event|
      (event.destroy && next) if event.object.nil? # if process has been destroyed
      begin
        event.data
      rescue => _error
        event.destroy # if data contains invalid process
      end
    end
  end

  private

  def dispatch_event
    EventDispatcher.process!(self)
  end

  def validate_data
    errors.add(:data, "should be a hash") unless data.nil? || data.is_a?(Hash)
  end
end

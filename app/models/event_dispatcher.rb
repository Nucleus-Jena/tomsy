class EventDispatcher
  def self.process!(event)
    if event.respond_to?(:notification_receivers)
      event.notification_receivers.each do |receiver|
        Notification.create!(user: receiver, event: event)
      end
    end
  end
end

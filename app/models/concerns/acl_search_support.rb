require "active_support/concern"

module AclSearchSupport
  extend ActiveSupport::Concern

  included do
    def acl_search_restrictions
      {acl_can_read: all_who_can_as_ids(:read, self)}
    end

    private

    def all_who_can_as_ids(action, object)
      user_ids = []
      User.find_each do |user|
        user_ids << user.id if user.can?(action, object)
      end
      user_ids
    end
  end

  class_methods do
  end
end

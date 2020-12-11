class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group

  after_commit :synchronize_search_acl, on: [:create, :update, :destroy]

  def synchronize_search_acl
    RunFullReindexJob.perform_later
  end
end

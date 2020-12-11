class Comment < ApplicationRecord
  belongs_to :author, class_name: "User"
  belongs_to :object, polymorphic: true

  validates_presence_of :message

  after_save :reindex_object

  private

  def reindex_object
    object.reindex
  end
end

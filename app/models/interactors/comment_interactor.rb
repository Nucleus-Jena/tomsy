class Interactors::CommentInteractor
  def self.create(message, object, user)
    throw new Error("create comment: Unsupported object type: " + object.class) unless object.respond_to? :contributors

    html_without_mention_labels, mentions = Services::Mentioning.extract_mentions(Services::EditorSanitizer.sanitize(message))
    user_mention_ids = Services::Mentioning.get_user_mentions(mentions)
    mentioned_users = User.where(id: user_mention_ids)

    comment = Comment.new(message: html_without_mention_labels, author: user, object: object)

    if comment.save!
      Events::CommentCreatedEvent.create(subject: user, object: comment, data: {mentioned_users: mentioned_users})
      add_contributor_if_needed(object, user)
      mentioned_users.each { |mu| add_contributor_if_needed(object, mu) }
    end

    comment
  end

  def self.add_contributor_if_needed(object, contributor)
    unless object.contributors.include?(contributor)
      object.contributors << contributor
      case object
      when Workflow::Task
        Events::TaskAddedContributorEvent.create(object: object, data: {new_contributor: contributor})
      when Workflow::Process
        Events::ProcessAddedContributorEvent.create(object: object, data: {new_contributor: contributor})
      when Ambition
        Events::AmbitionAddedContributorEvent.create(object: object, data: {new_contributor: contributor})
      else
        throw new Error("comment -> add_contributor_if_needed: Unsupported object type: " + object.class)
      end

      return true
    end

    false
  end
  private_class_method :add_contributor_if_needed
end

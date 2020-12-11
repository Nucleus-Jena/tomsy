class Interactors::AmbitionInteractor
  def self.create(user, attributes)
    ambition = Ambition.create(attributes)

    unless ambition.errors.any?
      ambition.update(assignee: user)
      add_contributor_if_needed(ambition, user)
      Events::AmbitionCreatedEvent.create(subject: user, object: ambition)
    end

    ambition
  end

  def self.delete(ambition, user)
    if !ambition.deleted && ambition.update(deleted: true)
      Events::AmbitionDeletedEvent.create(subject: user, object: ambition)
    end

    ambition.errors.none?
  end

  def self.close(ambition, user)
    if !ambition.closed && ambition.update(closed: true, state_updated_at: Time.now)
      Events::AmbitionCompletedEvent.create(subject: user, object: ambition)
    end

    ambition.errors.none?
  end

  def self.reopen(ambition, user)
    if ambition.closed && ambition.update(closed: false, state_updated_at: ambition.created_at)
      Events::AmbitionReopenedEvent.create(subject: user, object: ambition)
    end

    ambition.errors.none?
  end

  def self.update(ambition, params, user)
    old_title = ambition.title
    old_description = ambition.description

    ambition.title = params[:title] if params.key?(:title)
    if params.key?(:description)
      ambition.description, mentions = Services::Mentioning.extract_mentions(Services::EditorSanitizer.sanitize(params[:description]))
      user_mention_ids = Services::Mentioning.get_user_mentions(mentions)
    end

    if ambition.changed? && ambition.save
      if ambition.saved_change_to_title?
        Events::AmbitionChangedTitleEvent.create(subject: user, object: ambition, data: {new_title: ambition.title, old_title: old_title})
      end
      if ambition.saved_change_to_description?
        old_user_mention_ids = Services::Mentioning.get_user_mentions(Services::Mentioning.get_mentions(old_description))
        user_mention_ids -= old_user_mention_ids
        mentioned_users = User.where(id: user_mention_ids)

        Events::AmbitionChangedSummaryEvent.create(subject: user, object: ambition, data: {new_summary: ambition.description, old_summary: old_description, mentioned_users: mentioned_users})
        mentioned_users.each { |mu| add_contributor_if_needed(ambition, mu) }
      end
      add_contributor_if_needed(ambition, user)
    end

    ambition.errors.none?
  end

  def self.update_private_status(ambition, private, user)
    if ambition.update(private: private)
      if ambition.saved_change_to_private?
        Events::AmbitionChangedVisibilityEvent.create(subject: user, object: ambition, data: {new_visibility: ambition.private})
      end
      add_contributor_if_needed(ambition, user)
    end

    ambition.errors.none?
  end

  def self.update_assignee(ambition, assignee, user)
    old_assignee = ambition.assignee

    if (old_assignee != assignee) && ambition.update(assignee: assignee)
      Events::AmbitionAssignedEvent.create(subject: user, object: ambition, data: {new_assignee: assignee, old_assignee: old_assignee})
      add_contributor_if_needed(ambition, user)
    end

    ambition.errors.none?
  end

  def self.assign(ambition, assignee, user)
    old_assignee = ambition.assignee

    if (old_assignee != assignee) && ambition.update(assignee: assignee)
      Events::AmbitionAssignedEvent.create(subject: user, object: ambition, data: {new_assignee: assignee, old_assignee: old_assignee})
      add_contributor_if_needed(ambition, user)
    end

    ambition.errors.none?
  end

  def self.unassign(ambition, user)
    old_assignee = ambition.assignee

    if !ambition.assignee.nil? && ambition.update(assignee: nil)
      Events::AmbitionUnassignedEvent.create(subject: user, object: ambition, data: {old_assignee: old_assignee})
      add_contributor_if_needed(ambition, user)
    end

    ambition.errors.none?
  end

  def self.update_contributors(ambition, contributors, user)
    to_add = contributors - ambition.contributors
    to_remove = ambition.contributors - contributors

    if to_add.any? || to_remove.any?
      ambition.contributors = contributors

      if ambition.errors.none?
        to_add.each do |contributor|
          Events::AmbitionAddedContributorEvent.create(subject: user, object: ambition, data: {added_contributor: contributor})
        end

        to_remove.each do |contributor|
          Events::AmbitionRemovedContributorEvent.create(subject: user, object: ambition, data: {removed_contributor: contributor})
        end

        add_contributor_if_needed(ambition, user)
      end
    end

    ambition.errors.none?
  end

  def self.add_contributor(ambition, contributor, user)
    unless ambition.contributors.include?(contributor)
      ambition.contributors << contributor
      Events::AmbitionAddedContributorEvent.create(subject: user, object: ambition, data: {added_contributor: contributor})
      add_contributor_if_needed(ambition, user)
    end

    ambition.errors.none?
  end

  def self.remove_contributor(ambition, contributor, user)
    if ambition.contributors.delete(contributor).any?
      Events::AmbitionRemovedContributorEvent.create(subject: user, object: ambition, data: {removed_contributor: contributor})
      add_contributor_if_needed(ambition, user)
    end

    ambition.errors.none?
  end

  def self.update_processes(ambition, processes, user)
    to_add = processes - ambition.processes
    to_remove = ambition.processes - processes

    if to_add.any? || to_remove.any?
      ambition.processes = processes

      if ambition.errors.none?
        to_add.each do |process|
          Events::AmbitionAddedProcessEvent.create(subject: user, object: ambition, data: {added_process: process})
        end

        to_remove.each do |process|
          Events::AmbitionRemovedProcessEvent.create(subject: user, object: ambition, data: {removed_process: process})
        end

        add_contributor_if_needed(ambition, user)
      end
    end

    ambition.errors.none?
  end

  def self.add_process(ambition, process, user)
    unless ambition.processes.include?(process)
      ambition.processes << process
      Events::AmbitionAddedProcessEvent.create(subject: user, object: ambition, data: {added_process: process})
      add_contributor_if_needed(ambition, user)
    end

    ambition.errors.none?
  end

  def self.remove_process(ambition, process, user)
    if ambition.processes.delete(process).any?
      Events::AmbitionRemovedProcessEvent.create(subject: user, object: ambition, data: {removed_process: process})
      add_contributor_if_needed(ambition, user)
    end

    ambition.errors.none?
  end

  def self.add_contributor_if_needed(ambition, contributor)
    ambition.contributors << contributor unless ambition.contributors.include?(contributor)
  end
  private_class_method :add_contributor_if_needed
end

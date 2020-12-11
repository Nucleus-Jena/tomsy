class Interactors::TaskInteractor
  def self.update(task, params, user)
    old_description = task.description

    if params.key?(:description)
      task.description, mentions = Services::Mentioning.extract_mentions(Services::EditorSanitizer.sanitize(params[:description]))
      user_mention_ids = Services::Mentioning.get_user_mentions(mentions)
    end

    if task.changed? && task.save
      if task.saved_change_to_description?
        old_user_mention_ids = Services::Mentioning.get_user_mentions(Services::Mentioning.get_mentions(old_description))
        user_mention_ids -= old_user_mention_ids
        mentioned_users = User.where(id: user_mention_ids)

        Events::TaskChangedSummaryEvent.create(subject: user, object: task, data: {new_summary: task.description, old_summary: old_description, mentioned_users: mentioned_users})
        mentioned_users.each { |mu| add_contributor_if_needed(task, mu) }
      end
      add_contributor_if_needed(task, user)
    end

    task.errors.none?
  end

  def self.update_assignee(task, assignee, user)
    old_assignee = task.assignee

    if (old_assignee != assignee) && task.update(assignee: assignee)
      if assignee.nil?
        Events::TaskUnassignedEvent.create(subject: user, object: task, data: {old_assignee: old_assignee})
      else
        Events::TaskAssignedEvent.create(subject: user, object: task, data: {new_assignee: assignee, old_assignee: old_assignee})
      end
      add_contributor_if_needed(task, user)
    end

    task.errors.none?
  end

  def self.update_contributors(task, contributors, user)
    to_add = contributors - task.contributors
    to_remove = task.contributors - contributors

    if to_add.any? || to_remove.any?
      task.contributors = contributors

      if task.errors.none?
        to_add.each do |contributor|
          Events::TaskAddedContributorEvent.create(subject: user, object: task, data: {added_contributor: contributor})
        end

        to_remove.each do |contributor|
          Events::TaskRemovedContributorEvent.create(subject: user, object: task, data: {removed_contributor: contributor})
        end

        add_contributor_if_needed(task, user)
      end
    end

    task.errors.none?
  end

  def self.update_marked(task, marked, user)
    if marked === !task.marked?(user)
      if marked
        task.marked_by_users << user
      else
        task.marked_by_users.delete(user)
      end
    end

    task.errors.none?
  end

  def self.update_due_at(task, due_at, user)
    due_at = nil if due_at&.empty?
    old_due_at = task.due_at

    if (old_due_at != due_at) && task.update(due_at: due_at)
      Events::TaskChangedDueDateEvent.create(subject: user, object: task, data: {new_due_date: due_at&.to_date, old_due_date: old_due_at})
      add_contributor_if_needed(task, user)
    end

    task.errors.none?
  end

  def self.complete(task, user)
    if task.open?
      completed, events = task.complete
      if completed
        Events::TaskCompletedEvent.create(subject: user, object: task)
        events.each { |e| e.save }
      end
    end

    task.errors.none?
  end

  def self.update_data(task, task_data_params, user)
    if task.process.data_entity.update(task_data_params)
      add_contributor_if_needed(task, user)
    end

    task.process.data_entity.errors.none?
  end

  def self.create_document(task, task_document_params, user)
    new_doc = Document.create(task_document_params) { |doc|
      doc.data_entity = task.process.data_entity
    }

    if new_doc.errors.none?
      add_contributor_if_needed(task, user)
    end

    new_doc
  end

  def self.update_document(task, document, task_document_params, user)
    document.update(task_document_params)

    if document.errors.none?
      add_contributor_if_needed(task, user)
    end

    document
  end

  def self.destroy_document(task, document, user)
    if document.destroy
      add_contributor_if_needed(task, user)
    end

    document
  end

  def self.add_contributor_if_needed(task, contributor)
    task.contributors << contributor unless task.contributors.include?(contributor)
  end
  private_class_method :add_contributor_if_needed
end

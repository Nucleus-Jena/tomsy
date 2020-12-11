class Interactors::ProcessInteractor
  def self.create(process_definition, ambition, predecessor_process, user)
    process, events = Workflow::Process.create_from_definition(process_definition)

    unless process.errors.any?
      process.update(assignee: user)
      process.contributors << user unless process.contributors.include?(user)
      process.ambitions << ambition unless ambition.nil?
      Events::ProcessStartedEvent.create!(subject: user, object: process)
      events.each { |e| e.save }

      unless predecessor_process.nil?
        process.update(predecessor_process: predecessor_process)
        Events::ProcessAddedSuccessorProcessEvent.create!(subject: user, object: predecessor_process, data: {successor_process: process})
      end

    end

    process
  end

  def self.cancel(process, cancel_info, user)
    canceled, events = process.cancel(cancel_info, user)
    if canceled
      Events::ProcessCanceledEvent.create!(subject: user, object: process)
      add_contributor_if_needed(process, user)
      events.each { |e| e.save }
    end

    process.errors.none?
  end

  def self.update_assignee(process, assignee, user)
    old_assignee = process.assignee

    if (old_assignee != assignee) && process.update(assignee: assignee)
      if assignee.nil?
        Events::ProcessUnassignedEvent.create!(subject: user, object: process, data: {old_assignee: old_assignee})
      else
        Events::ProcessAssignedEvent.create!(subject: user, object: process, data: {new_assignee: assignee, old_assignee: old_assignee})
      end
      add_contributor_if_needed(process, user)
    end

    process.errors.none?
  end

  def self.update_contributors(process, contributors, user)
    to_add = contributors - process.contributors
    to_remove = process.contributors - contributors

    if to_add.any? || to_remove.any?
      process.contributors = contributors

      if process.errors.none?
        to_add.each do |contributor|
          Events::ProcessAddedContributorEvent.create!(subject: user, object: process, data: {added_contributor: contributor})
        end

        to_remove.each do |contributor|
          Events::ProcessRemovedContributorEvent.create!(subject: user, object: process, data: {removed_contributor: contributor})
        end

        add_contributor_if_needed(process, user)
      end
    end

    process.errors.none?
  end

  def self.update(process, params, user)
    old_title = process.title
    old_description = process.description

    process.title = params[:title] if params.key?(:title)
    if params.key?(:description)
      process.description, mentions = Services::Mentioning.extract_mentions(Services::EditorSanitizer.sanitize(params[:description]))
      user_mention_ids = Services::Mentioning.get_user_mentions(mentions)
    end

    if process.changed? && process.save
      if process.saved_change_to_title?
        Events::ProcessChangedTitleEvent.create!(subject: user, object: process, data: {new_title: process.title, old_title: old_title})
      end
      if process.saved_change_to_description?
        old_user_mention_ids = Services::Mentioning.get_user_mentions(Services::Mentioning.get_mentions(old_description))
        user_mention_ids -= old_user_mention_ids
        mentioned_users = User.where(id: user_mention_ids)

        Events::ProcessChangedSummaryEvent.create(subject: user, object: process, data: {new_summary: process.description, old_summary: old_description, mentioned_users: mentioned_users})
        mentioned_users.each { |mu| add_contributor_if_needed(process, mu) }
      end
      add_contributor_if_needed(process, user)
    end

    process.errors.none?
  end

  def self.update_private_status(process, private, user)
    if process.update(private: private)
      if process.saved_change_to_private?
        Events::ProcessChangedVisibilityEvent.create!(subject: user, object: process, data: {new_visibility: process.private})
      end
      add_contributor_if_needed(process, user)
    end

    process.errors.none?
  end

  def self.update_ambitions(process, ambitions, user)
    to_add = ambitions - process.ambitions
    to_remove = process.ambitions - ambitions

    if to_add.any? || to_remove.any?
      process.ambitions = ambitions

      if process.errors.none?
        to_add.each do |ambition|
          Events::AmbitionAddedProcessEvent.create!(subject: user, object: ambition, data: {added_process: process})
        end

        to_remove.each do |ambition|
          Events::AmbitionRemovedProcessEvent.create!(subject: user, object: ambition, data: {removed_process: process})
        end

        add_contributor_if_needed(process, user)
      end
    end

    process.errors.none?
  end

  def self.add_contributor_if_needed(process, contributor)
    process.contributors << contributor unless process.contributors.include?(contributor)
  end
  private_class_method :add_contributor_if_needed
end

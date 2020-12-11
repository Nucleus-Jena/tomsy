class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_admin?
      can :access, :rails_admin # grant access to rails_admin
      can :manage, :all # grant access to do anything on all models

    elsif user
      ##########
      # Simple Models
      ##########
      can :read, User
      can :read, Dossier

      ##########
      # Aufgaben
      ##########
      can [:read, :update, :update_assignee, :data, :update_marked], Workflow::Task do |task|
        member_of_group_when_public_or_contributor_or_assignee(user, task) ||
          member_of_group_when_public_or_contributor_or_assignee(user, task.process)
      end

      can [:update_contributors, :complete], Workflow::Task do |task|
        task.assignee == user ||
          task.process.assignee == user
      end

      ##########
      # Maßnahmen
      ##########

      # This normally should not be defined on an object. But because it's dependent on the definition class used
      # we have no other choice...
      can :create, Workflow::Process do |process|
        member_of_any_group(user, process.process_definition.groups)
      end

      can [:read, :update, :update_assignee], Workflow::Process do |process|
        member_of_group_when_public_or_contributor_or_assignee(user, process)
      end

      # Anzeige eines Prozesses wenn man den Task sehen darf. #TODO: evtl. can :read_basic einführen
      can :read, Workflow::Process do |process|
        process.tasks.any? { |task| member_of_group_when_public_or_contributor_or_assignee(user, task) }
      end

      can [:update_contributors, :cancel, :update_private_status], Workflow::Process do |process|
        process.assignee == user
      end

      ##########
      # Ziele
      ##########
      can :create, Ambition

      can [:read, :update], Ambition do |ambition|
        !ambition.private ||
          member_of_group_when_public_or_contributor_or_assignee(user, ambition)
      end

      can [:destroy, :toggle_completeness, :update_private_status, :update_contributors], Ambition do |ambition|
        ambition.assignee == user
      end

    end
  end

  def permissions_for_subject(subject)
    actions_for_subject(subject).map { |action| [action, can?(action, subject)] }.to_h
  end

  private

  def member_of_group_when_public_or_contributor_or_assignee(user, object_of_acl)
    object_of_acl.assignee == user ||
      object_of_acl.contributors.include?(user) ||
      member_of_group_and_public(user, object_of_acl)
  end

  def member_of_group_and_public(user, object_of_acl)
    groups = object_of_acl.process.process_definition.groups if object_of_acl.is_a?(Workflow::Task)
    groups = object_of_acl.process_definition.groups if object_of_acl.is_a?(Workflow::Process)
    groups = [] if object_of_acl.is_a?(Ambition) # for documentation
    public = !object_of_acl.private
    public && member_of_any_group(user, groups)
  end

  def member_of_any_group(user, groups)
    return false unless groups
    groups.any? { |group| user.in_group?(group) }
  end

  def actions_for_subject(subject)
    subjects = alternative_subjects(subject)

    selected_rules = rules.select { |rule|
      rule.subjects.any? do |rule_subject|
        subjects.any? do |subject|
          subject = subject.class unless subject.is_a?(Module) || subject.is_a?(Symbol)
          rule_subject.to_s == subject.to_s
        end
      end
    }

    selected_rules.map(&:actions).flatten.uniq
  end
end

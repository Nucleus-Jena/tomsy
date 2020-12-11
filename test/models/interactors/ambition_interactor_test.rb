require "test_helper"

class Interactors::AmbitionInteractorTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @user = User.find_by!(email: "admin@example.org")
    @ambition = Ambition.create(title: "Neues Test-Ziel")
  end

  test "#create should create ambition instance with assignee and contributor and create an event" do
    ambition = nil

    assert_difference -> { Events::AmbitionCreatedEvent.count } do
      assert_difference -> { Ambition.count } do
        ambition = Interactors::AmbitionInteractor.create(@user, {title: "test ambition"})
      end
    end

    assert_equal @user, ambition.assignee
    assert ambition.contributors.include?(@user)
  end

  test "#delete should set ambition as deleted and create event" do
    assert_difference -> { Ambition.not_deleted.count }, -1 do
      assert_difference -> { Events::AmbitionDeletedEvent.count } do
        Interactors::AmbitionInteractor.delete(@ambition, @user)
      end
    end
  end

  test "#close should close ambition and create an event" do
    assert_difference -> { Events::AmbitionCompletedEvent.count } do
      Interactors::AmbitionInteractor.close(@ambition, @user)
    end

    assert @ambition.closed
  end

  test "#reopen should reopen ambition and create an event" do
    @ambition.update!(closed: true)

    assert_difference -> { Events::AmbitionReopenedEvent.count } do
      Interactors::AmbitionInteractor.reopen(@ambition, @user)
    end

    assert_not @ambition.closed
  end

  test "#update should update the title and/or description of the ambition, add the current_user as contributor and create an event" do
    other_user = User.find_by!(email: "srs_user@example.org")

    params = ActionController::Parameters.new({
      ambition: {
        title: "Changed Title",
        description: "<p>Changed Description <mention m-id=\"#{other_user.id}\" m-type=\"user\"></mention></p>"
      }
    })

    assert_difference -> { Events::AmbitionChangedTitleEvent.count } do
      assert_difference -> { Events::AmbitionChangedSummaryEvent.count } do
        assert_difference -> { Notification.count } do
          Interactors::AmbitionInteractor.update(@ambition, params.require(:ambition).permit(:title, :description), @user)
        end
      end
    end

    assert_equal params[:ambition][:title], @ambition.title
    assert_equal params[:ambition][:description], @ambition.description
    assert @ambition.contributors.include?(@user)
    assert Events::AmbitionChangedSummaryEvent.last.mentioned_users.include?(other_user)
  end

  test "#update_private_status should update the private attribute of the ambition, add the user as contributor and create an event" do
    assert_difference -> { Events::AmbitionChangedVisibilityEvent.count } do
      Interactors::AmbitionInteractor.update_private_status(@ambition, true, @user)
    end

    assert @ambition.private?
    assert @ambition.contributors.include?(@user)
  end

  test "#assign should set an new assignee of the ambition, add the user as contributor and create an event" do
    assert_difference -> { Events::AmbitionAssignedEvent.count } do
      Interactors::AmbitionInteractor.assign(@ambition, @user, @user)
    end

    assert_equal @user, @ambition.assignee
    assert @ambition.contributors.include?(@user)
  end

  test "#unassign should clear the assignee of the ambition, add the user as contributor and create an event" do
    @ambition.update!(assignee: @user)

    assert_difference -> { Events::AmbitionUnassignedEvent.count } do
      Interactors::AmbitionInteractor.unassign(@ambition, @user)
    end

    assert_nil @ambition.assignee
    assert @ambition.contributors.include?(@user)
  end

  test "#add_contributor should add an user as contributor of the ambition, add the current user as contributor and create an event" do
    other_user = User.find_by!(email: "srs_user@example.org")

    assert_difference -> { Events::AmbitionAddedContributorEvent.count } do
      Interactors::AmbitionInteractor.add_contributor(@ambition, other_user, @user)
    end

    assert @ambition.contributors.include?(other_user)
    assert @ambition.contributors.include?(@user)
  end

  test "#remove_contributor should remove an user from the contributors of the ambition, add the current user as contributor and create an event" do
    other_user = User.find_by!(email: "srs_user@example.org")
    @ambition.contributors << other_user

    assert @ambition.contributors.include?(other_user)

    assert_difference -> { Events::AmbitionRemovedContributorEvent.count } do
      Interactors::AmbitionInteractor.remove_contributor(@ambition, other_user, @user)
    end

    assert_not @ambition.contributors.include?(other_user)
    assert @ambition.contributors.include?(@user)
  end

  test "#add_process should add a process to the ambition, add the current user as contributor and create an event" do
    process = Workflow::Process.first

    assert_difference -> { Events::AmbitionAddedProcessEvent.count } do
      Interactors::AmbitionInteractor.add_process(@ambition, process, @user)
    end

    assert @ambition.processes.include?(process)
    assert @ambition.contributors.include?(@user)
  end

  test "#remove_process should remove a process from the ambition, add the current user as contributor and create an event" do
    process = Workflow::Process.first
    @ambition.processes << process

    assert @ambition.processes.include?(process)

    assert_difference -> { Events::AmbitionRemovedProcessEvent.count } do
      Interactors::AmbitionInteractor.remove_process(@ambition, process, @user)
    end

    assert_not @ambition.processes.include?(process)
    assert @ambition.contributors.include?(@user)
  end
end

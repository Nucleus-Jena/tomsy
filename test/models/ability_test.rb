require "test_helper"

class AbilityTest < ActiveSupport::TestCase
  def setup
    @personas = ["no_access_user", "member_of_group", "contributor_and_member_of_group", "owner_and_member_of_group",
      "contributor", "owner"].map { |persona_name| create_user(persona_name) }
    @a_new_group = Group.create!(name: "a fresh new group")
    @a_new_group.users << User.find_by_email!("member_of_group@example.org")
    @a_new_group.users << User.find_by_email!("contributor_and_member_of_group@example.org")
    @a_new_group.users << User.find_by_email!("owner_and_member_of_group@example.org")

    @contributor_personas = [User.find_by_email!("contributor@example.org"), User.find_by_email!("contributor_and_member_of_group@example.org")]
  end

  test "general acl" do
    # Define all objects under Test
    @user = User.find_by!(email: "no_access_user@example.org")
    @user_klass = User

    personas = @personas.select { |p| p.lastname.match("no_access_user") }
    acl_rule_file = "test/fixtures/acl_definitions/acl_general.csv"

    test_all_acl_rules_for(acl_rule_file, personas, [@ambition, @private_ambition])
  end

  test "process acl" do
    patent_application_definition = Workflow::ProcessDefinition.find_by!(key: "patent_application")
    patent_application_definition.groups << @a_new_group
    @process, = Workflow::Process.create_from_definition(patent_application_definition)
    @private_process, = Workflow::Process.create_from_definition(patent_application_definition)
    set_process_private!(@private_process)

    @process.update!(contributors: @contributor_personas)
    @private_process.update!(contributors: @contributor_personas)

    acl_rule_file = "test/fixtures/acl_definitions/acl_process.csv"

    test_all_acl_rules_for(acl_rule_file, @personas, [@process, @private_process])
  end

  test "task acl" do
    # Additional personas which are only associated to process of task under test (but gain access through this)
    additional_task_personas = ["owner_of_process", "contributor_of_process"].map { |persona_name| create_user(persona_name) }
    @personas += additional_task_personas
    patent_application_definition = Workflow::ProcessDefinition.find_by!(key: "patent_application")
    patent_application_definition.groups << @a_new_group
    process, = Workflow::Process.create_from_definition(patent_application_definition)
    process.update!(assignee: User.find_by!(email: "owner_of_process@example.org"))
    process.contributors << User.find_by!(email: "contributor_of_process@example.org")
    @task = process.tasks.first
    private_process, = Workflow::Process.create_from_definition(patent_application_definition)
    set_process_private!(private_process)
    private_process.update!(assignee: User.find_by!(email: "owner_of_process@example.org"))
    private_process.contributors << User.find_by!(email: "contributor_of_process@example.org")
    @task_of_private_process = private_process.tasks.first

    @task.update!(contributors: @contributor_personas)
    @task_of_private_process.update!(contributors: @contributor_personas)

    acl_rule_file = "test/fixtures/acl_definitions/acl_task.csv"

    test_all_acl_rules_for(acl_rule_file, @personas, [@task, @task_of_private_process])
  end

  test "ambition acl" do
    @ambition = Ambition.create!(title: "Our very own Ziel")
    @private_ambition = Ambition.create!(title: "Our very own PRIVAT Ziel", private: true)

    @ambition.update!(contributors: @contributor_personas)
    @private_ambition.update!(contributors: @contributor_personas)

    personas = @personas.reject { |p| p.lastname.match("member_of_group") } # Play no Role for Ambitions
    acl_rule_file = "test/fixtures/acl_definitions/acl_ambition.csv"

    test_all_acl_rules_for(acl_rule_file, personas, [@ambition, @private_ambition])
  end

  private

  def set_process_private!(process)
    process.update!(private: true)
    process.reload # Otherwise tasks may have been cached and process.tasks[x].private may return false which leads to mysterious failing tests
  end

  def create_user(name)
    User.create!(email: "#{name}@example.org", lastname: name, firstname: "first name")
  end

  def test_all_acl_rules_for(acl_rule_file, personas, ownable_resources = [])
    CSV.foreach(acl_rule_file, headers: true, col_sep: ",").each_with_index do |row, line_count|
      next unless row["ACTION"].present?
      personas.each do |persona|
        raise "Persona #{persona.lastname.upcase} missing in #{acl_rule_file}" unless row[persona.lastname.upcase]

        # We have to switch owners because there only can be one
        ownable_resources.each { |resource| resource.update!(assignee: persona) } if persona.email.match?("owner")

        resource = instance_variable_get("@#{row["RESOURCE"]}")
        can_or_cannot = row[persona.lastname.upcase] == "yes" ? :can? : :cannot?
        action = row["ACTION"].to_sym
        acl_rule_under_test = "ACL für #{persona.lastname} #{can_or_cannot} #{action} #{row["RESOURCE"]} nicht korrekt (definiert in: #{acl_rule_file}:#{line_count + 2})"
        assert persona.send(can_or_cannot, action, resource), acl_rule_under_test
      end
    end
  end
end

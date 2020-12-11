require "test_helper"

class PatentApplicationTest < ActiveSupport::TestCase
  test "creating patent application should create workflow process" do
    process, = Workflow::Process.create_from_definition(
      Workflow::ProcessDefinition.find_by!(key: "patent_application")
    )
    process.ambitions << Ambition.create(title: "Blubb Ziel")
    patent_application = process.data_entity

    assert patent_application.process.present?
  end
end

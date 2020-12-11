require "test_helper"

class DossierDefinitionTest < ActiveSupport::TestCase
  def setup
    @dossier_definition = DossierDefinition.find_by(identifier: "person")
  end

  test "it should be possible to create a dossier definition" do
    assert_difference -> { DossierDefinition.count } do
      DossierDefinition.create(identifier: "test", label: "test")
    end
  end

  test "it should not be possible to save a dossier definition without label" do
    assert_not @dossier_definition.update(label: "")
    assert @dossier_definition.errors.details[:label].any?
  end

  test "it should not be possible to create a dossier definition without identifier or with wrong format" do
    dossier_definition_new = DossierDefinition.new(identifier: "test", label: "Test")

    dossier_definition_new.identifier = ""
    assert_not dossier_definition_new.save
    assert dossier_definition_new.errors.details[:identifier].any?
    dossier_definition_new.errors.clear

    dossier_definition_new.identifier = "test definition"
    assert_not dossier_definition_new.save
    assert dossier_definition_new.errors.details[:identifier].any?
    dossier_definition_new.errors.clear

    dossier_definition_new.identifier = "testDefinition"
    assert_not dossier_definition_new.save
    assert dossier_definition_new.errors.details[:identifier].any?
    dossier_definition_new.errors.clear

    dossier_definition_new.identifier = "test-definition"
    assert_not dossier_definition_new.save
    assert dossier_definition_new.errors.details[:identifier].any?
    dossier_definition_new.errors.clear

    dossier_definition_new.identifier = "test&definition"
    assert_not dossier_definition_new.save
    assert dossier_definition_new.errors.details[:identifier].any?
    dossier_definition_new.errors.clear
  end

  test "dossier definition identifiers should be unique" do
    dossier_definition_new = DossierDefinition.create(identifier: "person", label: "Person Kopie")
    assert dossier_definition_new.errors.details[:identifier].any?
  end

  test "it should not be possible to change the identifier of a dossier definition" do
    assert_not @dossier_definition.update(identifier: "person_changed")
    assert @dossier_definition.errors.details[:identifier].any?
  end

  test "dossier definition should have a name for rails admin" do
    assert_not_empty @dossier_definition.name
  end

  test "it should not be possible to add a non existing field to title_fields or to set it to a value other than an array" do
    @dossier_definition.title_fields << "non_existing_field_id"
    assert_not @dossier_definition.save
    assert @dossier_definition.errors.details[:title_fields].any?
    @dossier_definition.errors.clear

    @dossier_definition.title_fields = "email"
    assert_not @dossier_definition.save
    assert @dossier_definition.errors.details[:title_fields].any?
  end

  test "it should not be possible to add a non existing field to subtitle_fields or to set it to a value other than an array" do
    @dossier_definition.subtitle_fields << "non_existing_field_id"
    assert_not @dossier_definition.save
    assert @dossier_definition.errors.details[:subtitle_fields].any?
    @dossier_definition.errors.clear

    @dossier_definition.subtitle_fields = "email"
    assert_not @dossier_definition.save
    assert @dossier_definition.errors.details[:subtitle_fields].any?
  end
end

require "test_helper"

class DossierDefinitionFieldTest < ActiveSupport::TestCase
  def setup
    @dossier_definition = DossierDefinition.find_by(identifier: "person")
    @dossier_definition_field = @dossier_definition.fields.find_by(identifier: "email")
  end

  test "it should be possible to create a dossier definition field" do
    assert_difference -> { DossierDefinitionField.count } do
      DossierDefinitionField.create(definition: @dossier_definition, identifier: "test", label: "Test", position: 99, content_type: DossierDefinitionField.content_types[:string])
    end
  end

  test "it should not be possible to save a dossier definition field without label" do
    assert_not @dossier_definition_field.update(label: "")
    assert @dossier_definition_field.errors.details[:label].any?
  end

  test "it should not be possible to save a dossier definition field without position" do
    assert_not @dossier_definition_field.update(position: nil)
    assert @dossier_definition_field.errors.details[:position].any?
  end

  test "it should not be possible to create a dossier definition field without identifier or with wrong format" do
    dossier_definition_field_new = DossierDefinitionField.create!(definition: @dossier_definition, identifier: "test", label: "test", position: 99, content_type: DossierDefinitionField.content_types[:integer])

    dossier_definition_field_new.identifier = ""
    assert_not dossier_definition_field_new.save
    assert dossier_definition_field_new.errors.details[:identifier].any?
    dossier_definition_field_new.errors.clear

    dossier_definition_field_new.identifier = "test new"
    assert_not dossier_definition_field_new.save
    assert dossier_definition_field_new.errors.details[:identifier].any?
    dossier_definition_field_new.errors.clear

    dossier_definition_field_new.identifier = "testNew"
    assert_not dossier_definition_field_new.save
    assert dossier_definition_field_new.errors.details[:identifier].any?
    dossier_definition_field_new.errors.clear

    dossier_definition_field_new.identifier = "test-new"
    assert_not dossier_definition_field_new.save
    assert dossier_definition_field_new.errors.details[:identifier].any?
    dossier_definition_field_new.errors.clear

    dossier_definition_field_new.identifier = "test&new"
    assert_not dossier_definition_field_new.save
    assert dossier_definition_field_new.errors.details[:identifier].any?
    dossier_definition_field_new.errors.clear
  end

  test "dossier definition field identifiers should be unique in the context of the dossier definition" do
    dossier_definition_new = DossierDefinition.create!(identifier: "test", label: "test")

    dossier_definition_field_new = DossierDefinitionField.create(definition: @dossier_definition, identifier: "email", label: "E-Mail 2", position: 99, content_type: DossierDefinitionField.content_types[:string])
    assert dossier_definition_field_new.errors.details[:identifier].any?

    dossier_definition_field_new.definition = dossier_definition_new
    assert_difference -> { DossierDefinitionField.count } do
      dossier_definition_field_new.save
    end
  end

  test "dossier definition field position should be unique in the context of the dossier definition" do
    dossier_definition_new = DossierDefinition.create!(identifier: "test", label: "test")

    dossier_definition_field_new = DossierDefinitionField.create(definition: @dossier_definition, identifier: "test", label: "Test", position: @dossier_definition_field.position, content_type: DossierDefinitionField.content_types[:integer])
    assert dossier_definition_field_new.errors.details[:position].any?

    dossier_definition_field_new.definition = dossier_definition_new
    assert_difference -> { DossierDefinitionField.count } do
      dossier_definition_field_new.save
    end
  end

  test "it should not be possible to change the identifier of a dossier definition field" do
    assert_not @dossier_definition_field.update(identifier: "email_changed")
    assert @dossier_definition_field.errors.details[:identifier].any?
  end

  test "it should not be possible to change the definition of a dossier definition field" do
    dossier_definition_new = DossierDefinition.create!(identifier: "test", label: "Test")

    assert_not @dossier_definition_field.update(definition: dossier_definition_new)
    assert @dossier_definition_field.errors.details[:definition].any?
  end

  test "fields of a dossier definition are order by position" do
    dossier_definition_field_new = DossierDefinitionField.create!(definition: @dossier_definition, identifier: "test", label: "Test", position: 99, content_type: DossierDefinitionField.content_types[:integer])
    assert_equal dossier_definition_field_new, @dossier_definition.fields.last

    @dossier_definition_field.update!(position: 100)
    assert_equal @dossier_definition_field, @dossier_definition.fields.last
  end

  test "dossier definition field should have a name for rails admin" do
    assert_not_empty @dossier_definition_field.name
  end
end

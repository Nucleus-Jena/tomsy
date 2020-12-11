require "test_helper"

class DossierTest < ActiveSupport::TestCase
  def setup
    @dossier_definition = DossierDefinition.find_by(identifier: "person")
    @dossier = Dossier.find_by("data @> ?", {email: "admin@uni-jena.example.org"}.to_json)
  end

  test "it should be possible to create a dossier" do
    assert_difference -> { Dossier.count } do
      Dossier.create(
        definition: @dossier_definition,
        field_data: {"name" => "Test Person", "email" => "test@person.de", "organization" => "Test Organization", "notes" => "Lorem ipsum dolor sit amet.", "rating" => 10, "newsletter" => true}
      )
    end
  end

  test "it should not be possible to create a dossier without definition" do
    dossier_new = Dossier.new(definition: nil)
    assert_not dossier_new.save
    assert dossier_new.errors.details[:definition].any?
  end

  test "it should not be possible to change the definition of a dossier" do
    dossier_definition_new = DossierDefinition.create!(identifier: "new", label: "new")
    assert_not @dossier.update(definition: dossier_definition_new)
    assert @dossier.errors.details[:definition].any?
  end

  test "it should not be possible to change the created_by user of a dossier" do
    other_user = User.where.not(id: @dossier.created_by.id).first
    assert_not @dossier.update(created_by: other_user)
    assert @dossier.errors.details[:created_by].any?
  end

  test "it should not be possible to save a dossier without a required field" do
    @dossier.set_field_value("email", nil)
    assert_not @dossier.save
    assert @dossier.errors.details[:field_email].any?
  end

  test "it should not be possible to save a dossier with a already used value for a unique field" do
    dossier_new = Dossier.new(definition: @dossier_definition)
    dossier_new.set_field_value("email", @dossier.get_field_value("email"))
    assert_not dossier_new.save
    assert dossier_new.errors.details[:field_email].any?
  end

  test "data_fields method should return an array of hash with field definition and value" do
    assert_equal @dossier.definition.fields.count, @dossier.data_fields(false).count
    required_or_recommend_data_fields = @dossier.data_fields(true)
    assert_equal @dossier.definition.fields.required_or_recommended.count, required_or_recommend_data_fields.count
    assert_instance_of Array, required_or_recommend_data_fields
    assert_instance_of Hash, required_or_recommend_data_fields.first
    required_or_recommend_data_fields.first.assert_valid_keys(:definition, :value)
  end

  test "title should return a join string of all values of definition title_fields or a default value" do
    assert_equal @dossier.get_field_value("name"), @dossier.title
    @dossier.definition.title_fields = []
    assert_equal "#{@dossier.id} • #{@dossier.definition.label}", @dossier.title
  end

  test "title should return a join string of all values of definition subtitle_fields or empty string" do
    assert_equal "#{@dossier.get_field_value("email")} • #{@dossier.get_field_value("organization")}", @dossier.subtitle
    @dossier.definition.subtitle_fields = []
    assert_equal "", @dossier.subtitle
  end

  test "data must be a hash" do
    @dossier.data = []
    assert_not @dossier.save
    assert @dossier.errors.details[:data].any?
  end
end

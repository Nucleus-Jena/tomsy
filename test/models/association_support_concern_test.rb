require "test_helper"

class AssociationSupportConcernTest < ActiveSupport::TestCase
  def setup
    @dummy = AssociationSupportConcernTestDummy.create!
  end

  test "including the association concern should allow to use has_many_dossiers" do
    assert_empty @dummy.test_dossiers
    @dummy.update(test_dossier_ids: Dossier.first(2).map(&:id))
    assert_equal 2, @dummy.reload.test_dossiers.count
  end

  test "including the association concern should allow to use has_one_dossier" do
    assert_nil @dummy.test_dossier
    @dummy.update(test_dossier_id: Dossier.first.id)
    assert_equal Dossier.first, @dummy.reload.test_dossier
  end

  test "including the association concern should allow to use has_many_files" do
    assert_empty @dummy.test_files

    Document.create!(type: Document::FILE, title: "Jetz ein Titel", data_entity: @dummy, data_entity_field: :test_files)
    Document.create!(type: Document::FILE, title: "Jetz ein Titel", data_entity: @dummy, data_entity_field: :test_files)

    assert_equal 2, @dummy.reload.test_files.count
  end

  test "including the association concern should allow to use has_one_file" do
    assert_nil @dummy.test_file

    file = Document.create!(type: Document::FILE, title: "Jetz ein Titel", data_entity_id: @dummy.id, data_entity_field: :test_file)

    assert_equal file, @dummy.reload.test_file
  end

  test "#all_has_files_association_names returns the names of all defined has_x_files(s) associations" do
    defined_has_files_associations = [:test_files, :test_file].sort
    assert_equal defined_has_files_associations, AssociationSupportConcernTestDummy.all_has_files_association_names.sort
    assert_equal defined_has_files_associations, @dummy.all_has_files_association_names.sort
  end
end

class AssociationSupportConcernTestDummy < ProcessDataEntity
  include AssociationSupport

  has_many_dossiers :test_dossiers
  has_one_dossier :test_dossier
  has_many_files :test_files
  has_one_file :test_file
end

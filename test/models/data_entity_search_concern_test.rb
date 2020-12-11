require "test_helper"

class AssociationSupportConcernTest < ActiveSupport::TestCase
  test "search defaults should be provided for simple class" do
    simple_dummy = DataEntitySearchTestSimpleDummy.first!

    assert_nothing_raised { simple_dummy.search_defaults_for_data_entities }
  end

  test "search defaults should be provided for complex class" do
    complex_dummy = DataEntitySearchTestComplexDummy.first!

    assert_nothing_raised { complex_dummy.search_defaults_for_data_entities }
  end
end

# A class with attributes and associated files
class DataEntitySearchTestComplexDummy < ApplicationRecord
  self.table_name = "users" # to kind of fake a real AR object
  include DataEntitySearch
  include AssociationSupport

  has_many_files :test_files
  has_one_file :test_file
end

# We only have attributes to index.
class DataEntitySearchTestSimpleDummy < ApplicationRecord
  self.table_name = "users" # to kind of fake a real AR object
  include DataEntitySearch
end

require "active_support/concern"

module DataEntitySearch
  extend ActiveSupport::Concern

  included do
    def search_defaults_for_data_entities
      searchable_stuff = attributes
      searchable_stuff = add_all_files(searchable_stuff) if self.class.included_modules.include?(AssociationSupport)
      searchable_stuff
    end

    def add_all_files(searchable_stuff)
      all_has_files_association_names.each do |file_association|
        ensure_it_is_an_array_of_associations = [send(file_association.to_sym)].flatten.reject(&:nil?)
        ensure_it_is_an_array_of_associations.each do |document|
          searchable_stuff.merge!(document.search_data("document__#{file_association}__#{document.id}__"))
        end
      end
      searchable_stuff
    end
  end

  class_methods do
  end
end

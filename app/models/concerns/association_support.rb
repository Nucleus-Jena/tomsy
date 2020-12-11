require "active_support/concern"

module AssociationSupport
  extend ActiveSupport::Concern

  included do
    def all_has_files_association_names
      self.class.all_has_files_association_names
    end
  end

  class_methods do
    def has_many_dossiers(name)
      join_association_name = "dossier_associations_#{name}".to_sym

      has_many join_association_name, -> { for_field(name) }, class_name: DossierAssociation.name, as: :data_entity, dependent: :destroy
      has_many name.to_sym, through: join_association_name, source: :dossier
    end

    def has_one_dossier(name)
      join_association_name = "dossier_associations_#{name}".to_sym

      has_one join_association_name, -> { for_field(name) }, class_name: DossierAssociation.name, as: :data_entity, dependent: :destroy
      has_one name.to_sym, through: join_association_name, source: :dossier

      define_method("#{name}_id") do
        send(name)&.id
      end

      define_method("#{name}_id=") do |id|
        send("#{name}=", Dossier.find_by_id(id))
      end
    end

    def has_many_processes(name)
      join_association_name = "process_associations_#{name}".to_sym

      has_many join_association_name, -> { for_field(name) }, class_name: ProcessAssociation.name, as: :data_entity, dependent: :destroy
      has_many name.to_sym, through: join_association_name, source: :process
    end

    def has_many_files(name)
      has_many name.to_sym, -> { for_field(name) }, class_name: Document.name, as: :data_entity, dependent: :destroy
    end

    def has_one_file(name)
      has_one name.to_sym, -> { for_field(name) }, class_name: Document.name, as: :data_entity, dependent: :destroy
    end

    def all_has_files_association_names
      target = Document.name
      reflect_on_all_associations.select { |asso| asso.options[:class_name] == target }.map(&:name)
    end
  end
end

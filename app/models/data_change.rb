class DataChange
  def self.all_changes(object, attribute)
    klass = object.class

    if has_many_association?(attribute, klass)
      # we can only retrieve additions (not deletes for now)
      return object.send(attribute).map { |assoc_object| assoc_object.versions.last }
    end

    if has_one_association?(attribute, klass)
      object = object.send(attribute)
      attribute = :id
    end

    return [] unless object

    object.versions.select { |version|
      next unless version.object_changes.present?
      changes = YAML.load(version.object_changes) # rubocop:todo Security/YAMLLoad
      attribute_change = changes[attribute.to_s]
      attribute_change.present?

      # We used to check if current value and versioned one are equal to really get the last one (propably not necessary)
      # next unless attribute_change
      # new_value = attribute_change[1]

      # method_to_access_attribute = object.respond_to?("#{attribute}_before_type_cast".to_sym) ? "#{attribute}_before_type_cast".to_sym : attribute.to_sym
      # current_value = object.send(method_to_access_attribute)

      # new_value == current_value
    }
  end

  def self.who_changed_them_all(object, attribute)
    all_changes(object, attribute).map do |version|
      [User.find_by(id: version&.whodunnit), version]
    end
  end

  def self.who_changed_it_last(object, attribute)
    last_version_change = all_changes(object, attribute).last
    user_id = last_version_change&.whodunnit
    [User.find_by(id: user_id), last_version_change]
  end

  def self.has_many_association?(attribute_name, klass)
    has_association?("Many", attribute_name, klass)
  end

  def self.has_one_association?(attribute_name, klass)
    has_association?("HasOne", attribute_name, klass)
  end

  def self.has_association?(a_type, attribute_name, klass)
    matching_associations = klass.reflect_on_all_associations.select { |asso| asso.name == attribute_name.to_sym }
    matching_associations.any? && matching_associations.all? { |asso| asso.class.to_s.match(a_type) }
  end
end

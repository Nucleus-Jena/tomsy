class GlobalIdSerializer
  def self.load(value)
    return nil if value.nil?

    from_global_id(YAML.load(value)) # rubocop:todo Security/YAMLLoad
  end

  def self.dump(value)
    YAML.dump(to_global_id(value))
  end

  def self.to_global_id(value)
    if value.is_a?(Hash)
      value.map { |k, v| [k, to_global_id(v)] }.to_h
    elsif value.is_a?(Array)
      value.map { |v| to_global_id(v) }
    elsif value.is_a?(ApplicationRecord)
      value.to_global_id
    else
      value
    end
  end
  private_class_method :to_global_id

  def self.from_global_id(value)
    if value.is_a?(Hash)
      value.map { |k, v| [k, from_global_id(v)] }.to_h
    elsif value.is_a?(Array)
      value.map { |v| from_global_id(v) }
    elsif value.is_a?(GlobalID)
      GlobalID::Locator.locate value
    else
      value
    end
  end
  private_class_method :from_global_id
end

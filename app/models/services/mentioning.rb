class Services::Mentioning
  def self.get_mentions(html)
    _, mentions = extract_mentions(html, false)
    mentions
  end

  def self.extract_mentions(html, remove_mention_labels = true)
    mentions = {}

    html_without_mention_labels = iterate_mention_content(html) { |id, type, element|
      mentions[type] = mentions.fetch(type, []) | [id]
      element.content = nil if remove_mention_labels
    }

    [html_without_mention_labels, mentions]
  end

  def self.get_user_mentions(mentions)
    mentions.fetch("user", [])
  end

  def self.add_mention_labels(html, current_user)
    return html if html.nil? || html == ""

    iterate_mention_content(html) do |id, type, element|
      object = nil

      case type.to_sym
      when :user
        object = User.find_by(id: id)
      when :ambition
        object = Ambition.find_by(id: id)
      when :process
        object = Workflow::Process.find_by(id: id)
      when :task
        object = Workflow::Task.find_by(id: id)
      end

      noaccess = current_user.cannot?(:read, object)
      element.content = object.mention_label(noaccess) unless object.nil?
      element.set_attribute(":noaccess", true) if noaccess
      element.set_attribute(":deleted", true) if object.respond_to?(:deleted?) && object.deleted?
    end
  end

  def self.iterate_mention_content(html)
    html_fragment = Nokogiri::HTML.fragment(html)
    html_fragment.css("mention[m-id][m-type]").each do |element|
      id = element["m-id"]
      type = element["m-type"]

      yield id, type, element
    end

    html_fragment.to_html
  end

  private_class_method :iterate_mention_content
end

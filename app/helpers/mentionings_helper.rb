module MentioningsHelper
  def add_mention_labels(html, current_user)
    Services::Mentioning.add_mention_labels(html, current_user)
  end
end

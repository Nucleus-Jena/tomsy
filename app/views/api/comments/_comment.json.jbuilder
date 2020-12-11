json.message add_mention_labels(comment.message, current_user)
json.mentioned mentioned_users.present? && mentioned_users.include?(current_user)

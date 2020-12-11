class MentioningsHelperTest < ActionView::TestCase
  test "add_mention_labels should work for present and non present users" do
    user = User.first
    non_existing_user_id = "23423434"
    content = "Referencing a existing user #{user_mention(user.id)} and non existing #{user_mention(non_existing_user_id)}"
    content_expected = "Referencing a existing user #{user_mention(user.id, user.mention_label)} and non existing #{user_mention(non_existing_user_id)}"
    converted_content = add_mention_labels(content, user)
    assert_equal content_expected, converted_content
  end
end

def user_mention(id, text = "")
  "<mention m-id=\"#{id}\" m-type=\"user\">#{text}</mention>"
end

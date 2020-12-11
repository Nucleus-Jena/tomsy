require "test_helper"

class MentioningTest < ActiveSupport::TestCase
  test "should find a referenced user in a text" do
    an_existing_user = User.first
    content = "Lorem Ipsums blabla #{user_mention(an_existing_user.id, an_existing_user.mention_label)} Hello there"
    user_mention_ids = Services::Mentioning.get_user_mentions(Services::Mentioning.get_mentions(content))
    assert_equal [an_existing_user], User.where(id: user_mention_ids)
  end

  test "filtering editor content should remove mention labels" do
    editor_content = "<p>Dies ist ein Kommentar mit Erwähnung von #{user_mention(3, "@Lutz_Maicher")}.</p>"

    filtered_content, _ = Services::Mentioning.extract_mentions(editor_content)

    assert_equal "<p>Dies ist ein Kommentar mit Erwähnung von #{user_mention(3)}.</p>", filtered_content
  end

  test "sanitizing editor content should strip out not whitelisted html tags and comments" do
    content_good = "<p>Dies ist ein Kommentar mit Erwähnung von #{user_mention(3, "@Lutz_Maicher")}.</p>"
    content_bad = "<!-- This is a comment --><form>bla</form><script>alert('I am a hacker!')</script>"

    sanitized_content = Services::EditorSanitizer.sanitize(content_good + content_bad)

    assert_equal content_good, sanitized_content
  end
end

def user_mention(id, text = "")
  "<mention m-id=\"#{id}\" m-type=\"user\">#{text}</mention>"
end

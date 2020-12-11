require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "document with different types should all convert nicely to search_data" do
    file_doc = create_document_with("test/fixtures/files/cairo-multiline.pdf")
    assert file_doc.search_data

    link_doc = Document.create!(type: Document::LINK, link_url: "http://example.org/somewhere.html",
                                title: "A title is now required??",
                                data_entity: InitialMeetingInvention.first, data_entity_field: :rough_description)
    assert link_doc.search_data
  end

  test "pdf files should be converted to text" do
    document = create_document_with("test/fixtures/files/cairo-multiline.pdf")

    assert document.to_text.match("From James")
  end

  test "umlaute in pdfs should be convereted correctly" do
    document = create_document_with("test/fixtures/files/test-umlaute.pdf")

    assert document.to_text.match("Test Umläute!")
  end

  test "docx files should be converted to text" do
    document = create_document_with("test/fixtures/files/sample.docx")

    assert document.to_text.match("The quick brown fox jumped over the lazy cat.")
  end

  test "image files should be converted to text" do
    document = create_document_with("test/fixtures/files/table-screenshot.png")

    assert document.to_text.match("Zwischenergebnisse")
  end

  test "uploading files should trigger indexing job once" do
    assert_enqueued_with(job: ReindexSearchableJob) do
      create_document_with("test/fixtures/files/cairo-multiline.pdf")
    end
    assert_enqueued_with(job: ReindexSearchableJob) do
      Document.create!(type: Document::LINK, link_url: "http://example.org/somewhere.html",
                       title: "A title is now required??",
                       data_entity: InitialMeetingInvention.first, data_entity_field: :rough_description)
    end
  end

  private

  def create_document_with(file_name)
    document = Document.create!(type: Document::FILE, title: "A title is now required??", data_entity: InitialMeetingInvention.first, data_entity_field: :rough_description)
    File.open(file_name, "rb") do |pdf_test_file|
      document.file.attach(io: pdf_test_file, filename: "file_name")
    end
    document
  end
end

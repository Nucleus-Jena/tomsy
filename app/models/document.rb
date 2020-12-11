class Document < ApplicationRecord
  self.inheritance_column = "sti_type"
  has_paper_trail

  belongs_to :data_entity, polymorphic: true
  has_one_attached :file

  scope :for_id, ->(id) { where(data_entity_id: id) }
  scope :for_field, ->(field) { where(data_entity_field: field.to_s) }

  VALID_URL_REGEX = /\A(http|https|ftp|sftp):\/\/\S+\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix
  validates :type, :title, presence: true
  validates :link_url, presence: true, format: {with: VALID_URL_REGEX, message: "wrong format"}, if: :link?

  after_commit :reindex_data_entity

  LINK = "link"
  FILE = "file"

  DOCUMENT_TYPES = [LINK, FILE]

  def type=(new_type)
    unless new_type.in? DOCUMENT_TYPES
      raise "Allowed type values: #{DOCUMENT_TYPES}"
    end

    write_attribute(:type, new_type)
  end

  def link?
    type == LINK
  end

  def file?
    type == FILE
  end

  def reindex_data_entity
    # This is really tricky. Because ActiveStorage enqueues a job to actually process the attached file we can not access the blob/file for a long time
    # Thus directly calling .index causes an error... The only way around for now (there exist no callbacks - see for example https://github.com/rails/rails/issues/35044)

    ReindexSearchableJob.set(wait_until: 5.seconds.from_now).perform_later(data_entity&.process)
  end

  def to_text
    return nil unless file?
    return file_as_text if file_as_text.present?

    content_type = file.blob.content_type
    rest_client_response = RestClient::Request.execute(method: :put, url: Tika::Configuration.new.url,
                                                       headers: {"Content-Type": content_type},
                                                       payload: file.download)
    update(file_as_text: rest_client_response.force_encoding("UTF-8").to_s)
    file_as_text
  end

  def search_data(prefix = nil)
    {title: title,
     link: link_url,
     file_name: filename_for_search,
     file_content: to_text}.transform_keys { |key| "#{prefix}#{key}" }
  end

  def filename_for_search
    return nil unless file?
    filename = file.blob.filename.to_s
    searchable_filename = filename.gsub(/[.\-_]/, " ")
    [filename, searchable_filename].join("\n")
  end

  def self.destroy_invalid
    all.find_each do |document|
      document.destroy unless document.data_entity.nil?
    end
  end
end

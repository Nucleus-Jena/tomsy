class Services::EditorSanitizer < Rails::Html::Sanitizer
  class << self
    attr_accessor :allowed_tags
    attr_accessor :allowed_attributes
  end

  self.allowed_tags = Rails::Html::Sanitizer.safe_list_sanitizer.allowed_tags + %w[mention]
  self.allowed_attributes = Rails::Html::Sanitizer.safe_list_sanitizer.allowed_attributes + %w[m-id m-type]

  def initialize
    @permit_scrubber = Rails::Html::PermitScrubber.new
  end

  def sanitize(html, options = {})
    return unless html
    return html if html.empty?

    loofah_fragment = Loofah.fragment(html)

    @permit_scrubber.tags = self.class.allowed_tags
    @permit_scrubber.attributes = self.class.allowed_attributes
    remove_xpaths(loofah_fragment, Rails::Html::XPATHS_TO_REMOVE)
    loofah_fragment.scrub!(@permit_scrubber)

    properly_encode(loofah_fragment, encoding: "UTF-8")
  end

  def self.sanitize(html, options = {})
    new.sanitize(html, options)
  end
end

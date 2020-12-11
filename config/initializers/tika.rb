module Tika
  class Configuration
    DEFAULT_URL = "http://localhost:9998"

    def initialize
      @url = ENV["TIKA_URL"] || DEFAULT_URL
    end

    def url(path = "/tika")
      URI.join(@url, path).to_s
    end
  end
end

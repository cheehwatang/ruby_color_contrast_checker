# frozen_string_literal: true

require_relative "ruby_color_contrast_checker/version"
require "uri"
require "net/http"
require "json"

module RubyColorContrastChecker
  def self.valid_hex?(hex)
    !!(hex =~ /^[a-f0-9]{6}$/i) || !!(hex =~ /^[a-f0-9]{3}$/i)
  end

  def self.fetch_data(hex1, hex2)
    uri = URI("https://webaim.org/resources/contrastchecker/?fcolor=#{hex1}&bcolor=#{hex2}&api")
    response = Net::HTTP.get_response(uri)

    JSON.parse(response.body)
  end
end

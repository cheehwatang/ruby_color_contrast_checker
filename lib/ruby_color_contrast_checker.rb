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
    hex1 = convert_3hex_to_6hex(hex1) if hex1.length == 3
    hex2 = convert_3hex_to_6hex(hex2) if hex2.length == 3

    uri = URI("https://webaim.org/resources/contrastchecker/?fcolor=#{hex1}&bcolor=#{hex2}&api")
    response = Net::HTTP.get_response(uri)

    JSON.parse(response.body)
  end

  def self.convert_3hex_to_6hex(hex)
    chars = hex.chars
    "#{chars[0]}#{chars[0]}#{chars[1]}#{chars[1]}#{chars[2]}#{chars[2]}"
  end

  def self.prompt_input(message)
    print message
    gets.chomp
  end
end

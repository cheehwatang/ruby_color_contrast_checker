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

    uri = URI.parse("https://webaim.org/resources/contrastchecker/?fcolor=#{hex1}&bcolor=#{hex2}&api")
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

  def self.print_data(data)
    output = <<~MLS
      Contrast Ratio    : #{data["ratio"]}

      Level AA          : #{data["AA"].upcase}
      Level AA (Large)  : #{data["AALarge"].upcase}
      Level AAA         : #{data["AAA"].upcase}
      Level AAA (Large) : #{data["AAALarge"].upcase}
    MLS

    puts output
  end

  def self.run
    loop do
      puts
      first = prompt_input("Enter the first hex color string: \n> #")
      second = prompt_input("Enter the second hex color string: \n> #")
      puts

      if !valid_hex?(first) || !valid_hex?(second)
        puts "The Hex color code is invalid."
      else
        data = fetch_data(first, second)
        print_data(data)
      end

      puts
      input = prompt_input("Continue? (yes / no) ")
      break if input.downcase == "no"
    end
  end
end

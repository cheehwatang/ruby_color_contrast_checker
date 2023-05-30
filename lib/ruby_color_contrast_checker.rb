# frozen_string_literal: true

require_relative "ruby_color_contrast_checker/version"
require "uri"
require "net/http"
require "json"

module RubyColorContrastChecker
  def self.run
    Class.new { extend RubyColorContrastChecker }.run
  end

  def valid_hex?(hex)
    !!(hex =~ /^[a-f0-9]{6}$/i) || !!(hex =~ /^[a-f0-9]{3}$/i)
  end

  def fetch_data(hex1, hex2)
    hex1 = convert_3hex_to_6hex(hex1) if hex1.length == 3
    hex2 = convert_3hex_to_6hex(hex2) if hex2.length == 3

    uri = URI.parse("https://webaim.org/resources/contrastchecker/?fcolor=#{hex1}&bcolor=#{hex2}&api")
    response = Net::HTTP.get_response(uri)

    JSON.parse(response.body)
  end

  def convert_3hex_to_6hex(hex)
    chars = hex.chars
    "#{chars[0]}#{chars[0]}#{chars[1]}#{chars[1]}#{chars[2]}#{chars[2]}"
  end

  def prompt_input(message)
    print message
    gets.chomp
  end

  def red(string)
    "\e[31m#{string}\e[0m"
  end

  def green(string)
    "\e[32m#{string}\e[0m"
  end

  def colorize_float(float_string)
    return red(float_string) if Float(float_string) < 4.5

    green(float_string)
  end

  def colorize_status(status_string)
    status_string = status_string.upcase

    return red(status_string) if status_string == "FAIL"

    green(status_string)
  end

  def print_data(data)
    output = <<~MLS
      Contrast Ratio    : #{colorize_float(data["ratio"])}

      Level AA          : #{colorize_status(data["AA"])}
      Level AA (Large)  : #{colorize_status(data["AALarge"])}
      Level AAA         : #{colorize_status(data["AAA"])}
      Level AAA (Large) : #{colorize_status(data["AAALarge"])}
    MLS

    puts output
  end

  def run
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

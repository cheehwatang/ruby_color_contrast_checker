# frozen_string_literal: true

require_relative "ruby_color_contrast_checker/version"
require "uri"
require "net/http"
require "json"

module RubyColorContrastChecker
  def self.run
    Class.new { extend RubyColorContrastChecker }.run
  end

  def run
    print_welcome_message

    loop do
      puts
      first = prompt_input("\e[36mEnter the first hex color string:\e[0m \n\e[30m> #\e[0m")
      second = prompt_input("\e[36mEnter the second hex color string:\e[0m \n\e[30m> #\e[0m")
      puts

      if !valid_hex?(first) || !valid_hex?(second)
        print_error_message
      else
        data = fetch_data(first, second)
        print_data(data)
      end

      puts
      input = prompt_input("\e[33mContinue?\e[0m (\e[32myes\e[0m / \e[31mno\e[0m) ")
      break if input.downcase == "no"
    end
  end

  def valid_hex?(hex)
    !!(hex =~ /^[a-f0-9]{6}$/i) || !!(hex =~ /^[a-f0-9]{3}$/i)
  end

  def convert_3hex_to_6hex(hex)
    chars = hex.chars
    "#{chars[0]}#{chars[0]}#{chars[1]}#{chars[1]}#{chars[2]}#{chars[2]}"
  end

  def fetch_data(hex1, hex2)
    hex1 = convert_3hex_to_6hex(hex1) if hex1.length == 3
    hex2 = convert_3hex_to_6hex(hex2) if hex2.length == 3

    uri = URI.parse("https://webaim.org/resources/contrastchecker/?fcolor=#{hex1}&bcolor=#{hex2}&api")
    response = Net::HTTP.get_response(uri)

    JSON.parse(response.body)
  end

  def prompt_input(message)
    print message
    gets.chomp
  end

  def print_data(data)
    output = <<~MLS
      \e[36mContrast Ratio\e[0m    : #{colorize_float(data["ratio"])}

      \e[36mLevel AA\e[0m          : #{colorize_status(data["AA"])}
      \e[36mLevel AA (Large)\e[0m  : #{colorize_status(data["AALarge"])}
      \e[36mLevel AAA\e[0m         : #{colorize_status(data["AAA"])}
      \e[36mLevel AAA (Large)\e[0m : #{colorize_status(data["AAALarge"])}
    MLS

    puts output
  end

  def print_welcome_message
    welcome_message = <<~MLS
      \e[36m   ------------------------------------   \e[0m
      \e[36m  |  Welcome to Color Contrast Checker  | \e[0m
      \e[36m   ------------------------------------   \e[0m
                \\   ^__^
                 \\  (oo)_______
                    (__)\\       )\\/\\
                        ||----w |
                        ||     ||
    MLS

    puts welcome_message
  end

  def print_error_message
    puts "\e[31mThe Hex color code is invalid.\e[0m"
  end

  # Helper methods to colorize string based on the conditions.
  def colorize_float(float_string)
    return red(float_string) if Float(float_string) < 4.5

    green(float_string)
  end

  def colorize_status(status_string)
    status_string = status_string.upcase

    return red(status_string) if status_string == "FAIL"

    green(status_string)
  end

  # Helper methods to colorize string.
  def red(string)
    "\e[31m#{string}\e[0m"
  end

  def green(string)
    "\e[32m#{string}\e[0m"
  end
end

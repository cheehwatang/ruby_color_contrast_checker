# frozen_string_literal: true

require_relative "ruby_color_contrast_checker/version"

module RubyColorContrastChecker
  def self.valid_hex?(hex)
    !!(hex =~ /^[a-f0-9]{6}$/i) || !!(hex =~ /^[a-f0-9]{3}$/i)
  end
end

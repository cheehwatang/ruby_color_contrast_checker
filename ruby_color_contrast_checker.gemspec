# frozen_string_literal: true

require_relative "lib/ruby_color_contrast_checker/version"

Gem::Specification.new do |spec|
  spec.name = "ruby_color_contrast_checker"
  spec.version = RubyColorContrastChecker::VERSION
  spec.authors = ["Chee Hwa Tang"]
  spec.email = ["cheehwa.tang@gmail.com"]

  spec.required_ruby_version = ">= 3.1.2"
  spec.description = "CLI interface for WCAG Color Contrast Checking in Ruby "
  spec.homepage = "https://github.com/cheehwatang/ruby_color_contrast_checker"
  spec.summary = spec.description
  spec.license = "MIT"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/cheehwatang/ruby_color_contrast_checker/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.executables = ["contrast_checker"]
  spec.require_paths = ["lib"]
end

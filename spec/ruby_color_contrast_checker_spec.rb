# frozen_string_literal: true

RSpec.describe RubyColorContrastChecker do
  sut = RubyColorContrastChecker

  it "has a version number" do
    expect(RubyColorContrastChecker::VERSION).not_to be nil
  end

  context "self.valid_hex? method" do
    it "returns true if the 6-digits Hex string provided is valid" do
      expect(sut.valid_hex?("FFFFFF")).to be(true)
    end

    it "returns false if the 6-digits Hex string provided is invalid" do
      expect(sut.valid_hex?("GGGGGG")).to be(false)
    end

    it "returns true if the 3-digits Hex string provided is valid" do
      expect(sut.valid_hex?("000")).to be(true)
    end

    it "returns false if the 3-digits Hex string provided is invalid" do
      expect(sut.valid_hex?("GGG")).to be(false)
    end
  end

  context "self.fetch_data method" do
    it "takes 2 valid hex string arguments and returns hash of the json response" do
      actual = sut.fetch_data("000000", "FFFFFF")

      expect(actual).to eq({
        "ratio" => "21",
        "AA" => "pass",
        "AALarge" => "pass",
        "AAA" => "pass",
        "AAALarge" => "pass"
      })
    end
  end
end

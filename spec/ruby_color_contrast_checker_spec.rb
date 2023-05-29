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
    it "takes 2 valid 6-digit hex string arguments and returns hash of the json response" do
      actual = sut.fetch_data("000000", "FFFFFF")

      expect(actual).to eq({
        "ratio" => "21",
        "AA" => "pass",
        "AALarge" => "pass",
        "AAA" => "pass",
        "AAALarge" => "pass"
      })
    end

    it "takes 2 valid 3-digit hex string arguments and returns hash of the json response" do
      actual = sut.fetch_data("000", "FFF")

      expect(actual).to eq({
        "ratio" => "21",
        "AA" => "pass",
        "AALarge" => "pass",
        "AAA" => "pass",
        "AAALarge" => "pass"
      })
    end
  end

  context "self.convert_3hex_to_6hex method" do
    it "takes a valid 3-digit hex string argument and returns the 6-digit hex string" do
      inputs = ["000", "555", "aaa", "FFF"]
      expected = ["000000", "555555", "aaaaaa", "FFFFFF"]

      inputs.each_with_index do |input, index|
        actual = sut.convert_3hex_to_6hex(input)

        expect(actual).to eq(expected[index])
      end
    end
  end

  context "self.prompt_input method" do
    it "takes a message, prints the message and returns the user input" do
      allow(sut).to receive(:gets).and_return("ABC")
      message = "Please enter ABC"

      expect(sut.prompt_input(message)).to eq("ABC")
      expect { sut.prompt_input(message) }.to output(message).to_stdout
    end
  end

  context "self.print_data method" do
    it "takes in the data hash and print the data" do
      data = {
        "ratio" => "21",
        "AA" => "pass",
        "AALarge" => "pass",
        "AAA" => "pass",
        "AAALarge" => "pass"
      }

      expected = <<~MLS
        Contrast Ratio    : 21

        Level AA          : PASS
        Level AA (Large)  : PASS
        Level AAA         : PASS
        Level AAA (Large) : PASS
      MLS

      expect { sut.print_data(data) }.to output(expected).to_stdout
    end
  end
end

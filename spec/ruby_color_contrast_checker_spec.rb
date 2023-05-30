# frozen_string_literal: true

RSpec.describe RubyColorContrastChecker do
  it "has a version number" do
    expect(RubyColorContrastChecker::VERSION).not_to be nil
  end

  it "has a self.run method to start the app" do
    app_mock = Class.new { extend RubyColorContrastChecker }

    allow(Class).to receive(:new).and_return(app_mock)

    expect(app_mock).to receive(:run)

    RubyColorContrastChecker.run
  end

  let(:sut) { Class.new { extend RubyColorContrastChecker } }

  context "valid_hex? method" do
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

  context "fetch_data method" do
    it "takes 2 valid 6-digit hex string arguments and returns hash of the json response" do
      response = Net::HTTPSuccess.new(1.0, "200", "OK")
      hex1 = "000000"
      hex2 = "FFFFFF"

      expect(URI).to receive(:parse).with("https://webaim.org/resources/contrastchecker/?fcolor=#{hex1}&bcolor=#{hex2}&api").and_return("url")
      expect(Net::HTTP).to receive(:get_response).with("url").and_return(response)
      expect(response).to receive(:body).and_return("data")
      expect(JSON).to receive(:parse).with("data").and_return("data")

      actual = sut.fetch_data(hex1, hex2)

      expect(actual).to eq("data")
    end

    it "takes 2 valid 3-digit hex string arguments and returns hash of the json response" do
      response = Net::HTTPSuccess.new(1.0, "200", "OK")
      hex1 = "000"
      hex2 = "FFF"

      expect(URI).to receive(:parse).with("https://webaim.org/resources/contrastchecker/?fcolor=000000&bcolor=FFFFFF&api").and_return("url")
      expect(Net::HTTP).to receive(:get_response).with("url").and_return(response)
      expect(response).to receive(:body).and_return("data")
      expect(JSON).to receive(:parse).with("data").and_return("data")

      actual = sut.fetch_data(hex1, hex2)

      expect(actual).to eq("data")
    end
  end

  context "convert_3hex_to_6hex method" do
    it "takes a valid 3-digit hex string argument and returns the 6-digit hex string" do
      inputs = ["000", "555", "aaa", "FFF"]
      expected = ["000000", "555555", "aaaaaa", "FFFFFF"]

      inputs.each_with_index do |input, index|
        actual = sut.convert_3hex_to_6hex(input)

        expect(actual).to eq(expected[index])
      end
    end
  end

  context "prompt_input method" do
    it "takes a message, prints the message and returns the user input" do
      allow(sut).to receive(:gets).and_return("ABC")
      message = "Please enter ABC"

      expect(sut.prompt_input(message)).to eq("ABC")
      expect { sut.prompt_input(message) }.to output(message).to_stdout
    end
  end

  context "print_data method" do
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

  context "run method" do
    data = {"ratio" => "21"}

    it "start the cli app, input valid hex strings, print data and exit app" do
      allow(sut).to receive(:prompt_input).and_return("000", "FFF", "no")
      expect(sut).to receive(:fetch_data).with("000", "FFF").and_return(data)
      expect(sut).to receive(:print_data).with(data)

      sut.run
    end

    it "start the cli app, input invalid hex strings, print error message and exit app" do
      allow(sut).to receive(:prompt_input).and_return("000", "GGG", "no")
      expect(sut).not_to receive(:fetch_data)
      expect(sut).not_to receive(:print_data)

      expect { sut.run }.to output("\n\nThe Hex color code is invalid.\n\n").to_stdout
    end

    it "start the cli app and keep looping until user enters 'no' to exit the app" do
      allow(sut).to receive(:prompt_input).and_return("000", "FFF", "yes", "000", "FFF", "no")
      expect(sut).to receive(:fetch_data).twice.with("000", "FFF").and_return(data)
      expect(sut).to receive(:print_data).twice.with(data)

      sut.run
    end
  end
end

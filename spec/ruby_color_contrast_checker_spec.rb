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

  context "run method" do
    data = {"ratio" => "21"}

    it "start the cli app, input valid hex strings, print data and exit app" do
      allow(sut).to receive(:prompt_input).and_return("000", "FFF", "no")
      expect(sut).to receive(:get_result).with("000", "FFF").and_return(data)
      expect(sut).to receive(:print_data).with(data)

      sut.run
    end

    it "start the cli app, input invalid hex strings, print error message and exit app" do
      allow(sut).to receive(:prompt_input).and_return("000", "GGG", "no")
      expect(sut).not_to receive(:get_result)
      expect(sut).not_to receive(:print_data)
      expect(sut).to receive(:print_error_message)

      sut.run
    end

    it "start the cli app and keep looping until user enters 'no' to exit the app" do
      allow(sut).to receive(:prompt_input).and_return("000", "FFF", "yes", "000", "FFF", "no")
      expect(sut).to receive(:get_result).twice.with("000", "FFF").and_return(data)
      expect(sut).to receive(:print_data).twice.with(data)

      sut.run
    end
  end

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

  context "calculate_contrast_ratio method" do
    it "takes 2 6-digits hex value and returns the contrast ratio" do
      actual = sut.calculate_contrast_ratio("0088FF", "112233")

      expect(actual).to eq(4.59)
    end
  end

  context "convert_6hex_to_rgb_hash method" do
    it "takes a valid 6-digit hex string argument and returns the rgb hash" do
      inputs = ["0088FF", "112233"]
      expected = [{r: 0, g: 136, b: 255}, {r: 17, g: 34, b: 51}]

      inputs.each_with_index do |input, index|
        actual = sut.convert_6hex_to_rgb_hash(input)

        expect(actual).to eq(expected[index])
      end
    end
  end

  context "calculate_luminance method" do
    it "takes rgb hash and returns the relative luminance value" do
      inputs = [{r: 0, g: 136, b: 255}, {r: 17, g: 34, b: 51}]
      expected = [0.2483, 0.015]

      inputs.each_with_index do |input, index|
        actual = sut.calculate_luminance(input)

        expect(actual).to eq(expected[index])
      end
    end
  end

  context "pass_or_fail method" do
    it "takes a value and a threshold, and returns 'PASS' if at least threshold" do
      actual = sut.pass_or_fail(4.50, 4.5)

      expect(actual).to eq("PASS")
    end

    it "takes a value and a threshold, and returns 'FAIL' if less than threshold" do
      actual = sut.pass_or_fail(4.49, 4.5)

      expect(actual).to eq("FAIL")
    end
  end

  context "get_result method" do
    it "takes 2 valid 6-digit hex string arguments and returns result in hash" do
      hex1 = "000000"
      hex2 = "777777"
      expected = {
        "ratio" => "4.69",
        "AA" => "PASS",
        "AALarge" => "PASS",
        "AAA" => "FAIL",
        "AAALarge" => "PASS"
      }

      actual = sut.get_result(hex1, hex2)

      expect(actual).to eq(expected)
    end

    it "takes 2 valid 3-digit hex string arguments and returns result in hash" do
      hex1 = "000"
      hex2 = "777"
      expected = {
        "ratio" => "4.69",
        "AA" => "PASS",
        "AALarge" => "PASS",
        "AAA" => "FAIL",
        "AAALarge" => "PASS"
      }

      actual = sut.get_result(hex1, hex2)

      expect(actual).to eq(expected)
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
      allow(sut).to receive(:colorize_float).and_return("\e[32m21\e[0m")
      allow(sut).to receive(:colorize_status).and_return("\e[32mPASS\e[0m")

      data = {
        "ratio" => "21",
        "AA" => "pass",
        "AALarge" => "pass",
        "AAA" => "pass",
        "AAALarge" => "pass"
      }

      expected = <<~MLS
        \e[36mContrast Ratio\e[0m    : \e[32m21\e[0m

        \e[36mLevel AA\e[0m          : \e[32mPASS\e[0m
        \e[36mLevel AA (Large)\e[0m  : \e[32mPASS\e[0m
        \e[36mLevel AAA\e[0m         : \e[32mPASS\e[0m
        \e[36mLevel AAA (Large)\e[0m : \e[32mPASS\e[0m
      MLS

      expect { sut.print_data(data) }.to output(expected).to_stdout
    end
  end

  context "print_welcome_message method" do
    it "should print welcome message" do
      expected = <<~MLS
        \e[36m   ------------------------------------   \e[0m
        \e[36m  |  Welcome to Color Contrast Checker  | \e[0m
        \e[36m   ------------------------------------   \e[0m
                  \\   ^__^
                   \\  (oo)_______
                      (__)\\       )\\/\\
                          ||----w |
                          ||     ||
      MLS

      expect { sut.print_welcome_message }.to output(expected).to_stdout
    end
  end

  context "print_error_message method" do
    it "should print error message" do
      expected = "\e[31mThe Hex color code is invalid.\e[0m\n"

      expect { sut.print_error_message }.to output(expected).to_stdout
    end
  end

  context "colorize_float method" do
    it "takes a float string and colorize to red if float value less than 4.5" do
      red_string = "\e[31m1.0\e[0m"

      allow(sut).to receive(:red).and_return(red_string)
      actual = sut.colorize_float("1.0")

      expect(actual).to eq(red_string)
    end

    it "takes a float string and colorize to green if float value at least 4.5" do
      green_string = "\e[32m21\e[0m"

      allow(sut).to receive(:green).and_return(green_string)
      actual = sut.colorize_float("21")

      expect(actual).to eq(green_string)
    end
  end

  context "colorize_status method" do
    it "takes a string, upcase and return the red string if the upcase is equal to 'FAIL'" do
      red_string = "\e[31mFAIL\e[0m"

      allow(sut).to receive(:red).and_return(red_string)
      actual = sut.colorize_status("fail")

      expect(actual).to eq(red_string)
    end

    it "takes a string, upcase and return the green string if the upcase is not equal to 'FAIL'" do
      green_string = "\e[32mPASS\e[0m"

      allow(sut).to receive(:green).and_return(green_string)
      actual = sut.colorize_status("pass")

      expect(actual).to eq(green_string)
    end
  end

  context "red method" do
    it "takes a string and return red color string" do
      actual = sut.red("1.0")

      expect(actual).to eq("\e[31m1.0\e[0m")
    end
  end

  context "green method" do
    it "takes a string and return green color string" do
      actual = sut.green("21")

      expect(actual).to eq("\e[32m21\e[0m")
    end
  end
end

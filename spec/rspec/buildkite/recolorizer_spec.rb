# frozen_string_literal: true

RSpec.describe RSpec::Buildkite::Recolorizer do
  describe ".recolorize" do
    it "converts ANSI color codes to HTML spans" do
      input = "\e[31mred text\e[0m"
      result = described_class.recolorize(input)

      expect(result).to include('class="term-fg31"')
      expect(result).to include("red text")
      expect(result).to include("</span>")
    end

    it "handles multiple color codes" do
      input = "\e[1;31mbold red\e[0m"
      result = described_class.recolorize(input)

      expect(result).to include("term-fg1")
      expect(result).to include("term-fg31")
    end

    it "does not raise FrozenError with frozen_string_literal enabled" do
      # This test verifies the fix for the FrozenError that occurred
      # when the internal buffer was a frozen empty string literal.
      # The fix uses (+"") to create a mutable string.
      input = "\e[32mgreen\e[0m"

      expect { described_class.recolorize(input) }.not_to raise_error
    end

    it "handles strings without ANSI codes" do
      input = "plain text"
      result = described_class.recolorize(input)

      expect(result).to eq("plain text")
    end

    it "handles 256-color foreground codes" do
      input = "\e[38;5;196mcolor\e[0m"
      result = described_class.recolorize(input)

      expect(result).to include("term-fgx196")
    end

    it "handles 256-color background codes" do
      input = "\e[48;5;21mcolor\e[0m"
      result = described_class.recolorize(input)

      expect(result).to include("term-bgx21")
    end
  end
end

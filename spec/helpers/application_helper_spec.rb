require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#format_key" do
    it "converts snake_case to capitalized words" do
      expect(helper.format_key('test_key')).to eq('Test Key')
    end

    it "handles single word keys" do
      expect(helper.format_key('key')).to eq('Key')
    end

    it "handles keys with multiple underscores" do
      expect(helper.format_key('another_test_key')).to eq('Another Test Key')
    end

    it "handles empty string" do
      expect(helper.format_key('')).to eq('')
    end

    it "handles keys with numbers" do
      expect(helper.format_key('key_123')).to eq('Key 123')
    end
  end
end

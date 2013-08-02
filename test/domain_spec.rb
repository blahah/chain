require 'minitest/autorun'
require 'chain/domain'

describe Domain, "An application domain for chain" do
  before do
    @domain = Domain.new
  end

  after do
    @domain.destroy!
  end

  subject do
    Array.new.tap do |attributes|
      attributes << "silly hats"
      attributes << "skinny jeans"
    end
  end

  let(:list) { Array.new }

  describe "when asked about the font" do
    it "should be helvetica" do
      @hipster.preferred_font.must_equal "helvetica"
    end
  end

  describe "when asked about mainstream" do
    it "won't be mainstream" do
      @hipster.mainstream?.wont_equal true
    end
  end
end
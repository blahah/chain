require 'minitest/autorun'
require 'chain/program'

describe Program, "New programs are specified without programming" do
  before do
    @domain = Program.new
  end

  after do
    @domain.destroy!
  end

  let(:list) { Array.new }

  describe "when asked to add a program path" do
    it "should parse the help message" do
      path = '/usr/local/bin/bowtie-1.0.0/bowtie'
      p = Program.add('/usr/local/bin/bowtie-1.0.0/bowtie')
      p.definition['path'].must_equal path
    end
  end

  describe "when asked to add a valid JSON spec" do
    it "should successfully add the program" do
      @hipster.mainstream?.wont_equal true
    end
  end

  describe "when asked to add an invalid JSON spec" do
    it "should reject the spec and warn the user" do
      @hipster.mainstream?.wont_equal true
    end
  end

end
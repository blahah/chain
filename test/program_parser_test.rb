require 'chain/program_parser'
require 'test_helper'

class ProgramParserTest < Test::Unit::TestCase

  def setup

  end

  def teardown

  end

  def test_parsing_captures_bowtie
    # parse the help file
    bowtie1 = ProgramParser.new('/usr/local/bin/bowtie-1.0.0/bowtie')
    p = bowtie1.parse[:arguments]
    # minimum insert size
    mi = {
      :arg=>["-X", "--maxins"],
      :type=>:integer,
      :desc=>"maximum insert size for paired-end alignment (default: 250)",
      :default=>250
    }
    pmi = p['-X']
    assert_equal(mi[:arg], pmi[:arg])
    assert_equal(mi[:type], pmi[:type])
    assert_equal(mi[:default], pmi[:default])
  end

  def test_parsing_captures_bowtie2
    bowtie2 = ProgramParser.new('/usr/local/bin/bowtie2-2.1.0/bowtie2')
    p = bowtie2.parse[:arguments]
  end

  def test_parsing_captures_tophat
    tophat = ProgramParser.new('/usr/local/bin/tophat-2.0.9/tophat')
    p = tophat.parse[:arguments]
  end

  def test_parsing_captures_cufflinks
    cufflinks = ProgramParser.new('/usr/local/bin/cufflinks-2.1.1/cufflinks')
    p = cufflinks.parse[:arguments]
  end

  def test_parsing_captures_express
    express = ProgramParser.new('/usr/local/bin/express-1.3.1/express')
    p = express.parse[:arguments]
  end

  def test_parsing_captures_cap3
    cap3 = ProgramParser.new('/usr/local/bin/cap3/cap3')
    p = cap3.parse[:arguments]
  end

end
  
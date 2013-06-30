require 'bio'

$linechars = { 'fastq' => '@',
               'fasta' => '>' }

class Readtools

  def self.interleave(l, r, del=false)
    # interleave reads, returning filename
    # prepare parsers depending on read format
    bothfile = 'inter.' + File.basename(l)
    type = self.detect_type(l)
    if type == 'fastq'
      cmd = File.join(SCRIPTS_DIR, 'interleave_fastq.sh')
      `#{cmd} #{l} #{r} > #{bothfile}`
    elsif type == 'fasta'
      lhandle = Bio::FastaFormat.new.new(l)
      rhandle = Bio::FastaFormat.new.new(r)
      # interleave
      File.open(bothfile, 'w') do |outfile|
        # <3 you Ruby - this is poetry
        lhandle.each.zip(rhandle.each).each do |lread, rread|
          outfile.puts lread.to_s
          outfile.puts rread.to_s
        end
      end
    end
    # cleanup?
    [l, r].each { |f| File.delete(f) } if del
    return bothfile
  end

  def self.deinterleave(both, del=false)
    # deinterleave reads, returning l and r filenames
    # prepare file handles
    bothbase = File.basename(both)
    lfile, rfile = 'l.' + bothbase, 'r.' + bothbase
    type = self.detect_type(both)
    if type == 'fastq'
      cmd = File.join(SCRIPTS_DIR, 'deinterleave_fastq.sh')
      `#{cmd} < #{both} #{lfile} #{rfile}`
    elsif type == 'fasta'
      lhandle, rhandle = File.open(lfile, 'w'), File.open(rfile, 'w')
      i = 1
      Bio::FastaFormat.new(both).each do |read|
        i % 2 ? rhandle.puts(read.to_s) : lhandle.puts(read.to_s)
        i += 1
      end
    end
    # cleanup?
    File.delete(both) if del
    return [lfile, rfile]
  end

  def self.detect_type(reads)
    # detect format of reads file
    File.open(reads).each do |line|
      if line.strip == ""
        next
      else
        if line.start_with? ">"
          return 'fasta'
        elsif line.start_with? "@"
          return 'fastq'
        else
          return 'unknown'
        end
      end
    end
  end

end
class Khmer < Program

  def initialize(opts={})
    @path = File.join(APPS_DIR, "khmer-master/scripts/normalize-by-median.py")  
    @opts = self.load_options(opts)
  end

  def run(inputs)
    puts "Program: Khmer"
    inputs = self.norm_paired(inputs) if inputs.has_key?(:pairedreads)
    inputs = self.norm_single(inputs) if inputs.has_key?(:singlereads)
    return inputs
  end

  def load_options(opts)
    # merge default options with any provided
    defaults = {
      'N' => 4, # number of hashes
      'x' => 2e8, # hash size in bits (? docs are unclear)
      'k' => 20 # k-mer size
    }
    return defaults.merge(opts)
  end

  def option_string
    # parse options into command string
    cmd = ""
    @opts.each_pair do |opt, val|
      if val.is_a?(TrueClass) || val.is_a?(FalseClass)
        # option is a flag
        cmd += " -#{opt}" if val
      else
        cmd += " -#{opt} #{val}"
      end
    end
    return cmd
  end

  def norm_paired(inputs)
    # normalise paired-end reads
    # saving the hash if there are single-end reads to
    # normalise afterwards
    l, r = inputs[:pairedreads]
    puts "- normalising paired reads from #{l}:#{r} with Khmer"
    cmd = self.option_string
    # save hash?
    if inputs.has_key?(:singlereads)
      cmd += " --savehash #{l}.kh" 
      inputs[:kmerhash] = "#{l}.kh"
    end
    # interleave reads
    require 'readtools'
    both = Readtools.interleave(l, r, del=true)
    cmd += " #{both}"
    # run command
    `#{@path} #{cmd.lstrip} &> log.log`
    File.delete(both)
    # deinterleave reads
    l, r = Readtools.deinterleave(both + '.keep', del=true)
    inputs[:pairedreads] = [l, r].map {|f| File.basename(f) + '.keep'}
    return inputs
  end

  def norm_single(inputs)
    # normalise single-end reads
    # loading the hash from paired-end normalisation
    # if it exists
    reads = inputs[:singlereads]
    puts "- normalising single reads from #{reads} with Khmer"
    cmd = self.option_string
    # load hash?
    if inputs.has_key?(:kmerhash)
      cmd += " --loadhash #{inputs[:kmerhash]}"
    end
    # add reads
    cmd += " #{reads}"
    # run command
    `#{@path} #{cmd.lstrip} &> log.log`
    # File.remove(reads)
    inputs[:singlereads] = File.basename(reads) + '.keep'
    return inputs
  end

end
class Oases < Program

  def initialize(opts={})
    @vhpath = File.join(APPS_DIR, "khmer-master/scripts/normalize-by-median.py")  
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

end
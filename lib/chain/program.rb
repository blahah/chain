require 'settings'
require 'json'

# extend String to implement camelize from Rails
class String
  def camelize
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end

class Program
  def initialize(spec=nil, opts={})
    if !spec.nil? && spec.length > 0
      # parse JSON to hash if necessary
      if spec.class == String
        d = JSON.parse(definition)
      elsif spec.class == Hash
        d = spec
      end
      @name = d[:name]
      @path = d[:path]
      @arguments => d[:args]
    else
      raise "can't initalize program: invalid specification"
    end
  end

  def self.load(name)
    require_relative File.join(PROGS_DIR, name + '.rb')
    program_name = name.camelize
    program = Module.const_get(program_name)
    return program.new
  end

  def run(inputs)
    raise NotImplementedError.new("You must implement this")
  end

end
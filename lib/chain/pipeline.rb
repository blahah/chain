require 'program'
require 'settings'
require 'json'

class Pipeline
  def initialize(definition)
    # create a Pipeline instance from the
    # definition provided
    if Pipeline.can_parse? definition
      p = Pipeline.parse definition
      @name = p[:name]
      @description = p[:description]
      @programs = []
      p[:programs].each do |program|
        # initialize the programs
        @programs << Program.load(program)
      end
    else
      raise "Can't parse pipeline definition"
    end
  end

  def self.exist?(name)
    # check if saved pipeline with name exists
    return File.exist?(File.join(CHAIN_DIR, name + CHAIN_EXT))
  end

  def self.can_parse?(definition)
    JSON.parse definition
    true
  rescue JSON::ParserError, TypeError
    false
  end

  def self.parse(definition)
    # return hash from definition
    JSON.parse(definition)
  end

  def self.define(definition, name, description, inputs)
    # save definition for pipeline with name
  end

  def self.load(name)
    # return definition for pipeline with name
    Dir.chdir(CHAIN_DIR) do
      return File.open(name + CHAIN_EXT).readlines
    end
  end

  def self.run(name, inputs)
    # run pipelne by name
    if exist? name
      p = Pipeline.new(Pipeline.load(name))
      p.run(inputs)
    end
  end

  def run(inputs)
    # run self
    puts '-' * 30
    puts "Running pipeline: #{@name}..."
    puts '-' * 30
    t1 = Time.now
    @programs.each do |program|
      output = program.run(inputs)
      inputs = output
    end
    puts "finished in #{Time.now - t1} seconds"
  end

  def self.list
    # list all pipeline definitions in store
    chainnames = []
    Dir.chdir(CHAIN_DIR) do
      Dir['*.chain'].each do |chain|
        chainnames << chain
      end
    end
    chains = []
    if chainnames.length > 0
      puts '-' * 30
      puts 'Installed chains:'
      puts '-' * 30
      chainnames.each do |chain|
        c = Pipeline.load(File.basename(chain, CHAIN_EXT))
        c = Pipeline.parse(c)
        chains << c
        Pipeline.print(c)
      end
    end
    return chains
  end

  def self.print(pipeline)
    # pretty-print pipeline
    puts "#{pipeline[:name]} (#{pipeline[:description]})"
    progs = "\t"
    pipeline[:programs].each_with_index do |p, j|
      progs += "\n\t" if j+1 % 3 == 0
      progs += "#{j+1}. #{p} "
    end
    puts progs
  end
end
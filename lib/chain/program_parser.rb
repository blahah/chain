require 'pp'

class ProgramParser

	def initialize(path='', name='')
		# raise 'ERROR: cannot parse program: no file at that path!' unless File.exists? path
		@path = path
		@name = name
	end

  def parse
    # parse program's help message, generate the arguments hash, and store the definition
    raise 'ERROR: could not retrieve help message: please define the program manually' unless self.gethelp
    raise 'ERROR: could not parse retrieved help message: please define manually' unless self.parse_help
    @program = {
      :name => @name,
      :path => @path,
      :arguments => @args
    }
  end

  # we hope the program will respond with the help message
  # to one of these arguments
  HelpFlags = ['', ' -h', ' -help', ' --help']

  def gethelp
    # attempt to retrieve the help message
    HelpFlags.each do |helpflag|
      `#{@path + helpflag} &> capturehelpmsg.tmp`
      helpmsg = File.open('capturehelpmsg.tmp').read
      File.delete('capturehelpmsg.tmp')
      # note: do we need to check exit status?
      # bowtie, tophat and cufflinks exit 0, 1, 2 repsectively
      # when run with no args - not consistent
      unless helpmsg.split(/\n/).length > 1
        next
      end
      @helpmsg = helpmsg
      return true
    end
    false
  end

  def parse_help
    # parse out arguments from help message
    lines = @helpmsg.split(/\n/)
    args = {}
    lines.each do |line|
      line = line.strip
      next if line =~
      d = nil
      if line =~ /\t/
        segments = line.split(/\t/)
        d = self.parse_segments segments
      else
        segments = line.split(/\s{2,}/)
        d = self.parse_segments segments
      end
      unless d.nil?
        d[:default] = self.guess_default(d)
        args[d[:arg][0]] = d
      end
    end
    @args = args
    return true
  # rescue Exception => e
  #   puts "error trying to parse help: #{e}"
  #   nil
  end

  def parse_segments(segments)
    # extract argument data from parts of a help line
    if segments.length > 1
      arg = {}
      remaining = [] # to collect any unused segments for description
      gotflags = false
      segments.each do |segment|
        if segment =~ /:$/
          # ignore headings like "Heading:"
          next
        elsif segment =~ /^-+/
          # capture the flags!
          parts = segment.split(' ')
          parts.each do |part|
            if part =~ /-{1,2}[a-zA-Z0-9]+/ && !gotflags
              # flags/arguments
              a = part.split(/[\/\s]/)
              a = a.each{ |f| f.scan(/(-{1,2}[a-zA-Z0-9]+)/) }
              arg[:arg] = a
              gotflags = true
            elsif part =~ /<.*>/
              # type
              type = self.extract_type(part)
              arg[:type] = type if type
            else
              # save it for description
              remaining << part
            end
          end
          arg[:type] ||= 'flag'
        else
          if segment =~ /<.*>/
            # type
            type = self.extract_type(segment)
            arg[:type] = type if type
          end
          # save it for description
          remaining << segment
        end
      end
      arg[:desc] = remaining.join(', ').strip if (gotflags && remaining.length > 0)
      return arg.length > 0 ? arg : nil
    end
    nil
  end

  # we use these lists of keywords to detect argument types
  StringTypes = %w(string str file fname filename path text)
  IntTypes = %w(int integer long longint number value)
  FloatTypes = %w(float decimal fraction prop proportion prob probability)

  def extract_type(part)
    # try to return the type for an argument
    typeword = /<([^>]+)>/.match(part)[1]
    unless typeword.nil?
      return :string if StringTypes.include? typeword
      return :integer if IntTypes.include? typeword
      return :float if FloatTypes.include? typeword
    end
    nil
  end

  # we use these defaults if we can't guess values from the help line
  # having something as a placeholder allows the user to easily replace
  # the default value without having to create the data structure
  Defaults = {
    'string' => 'change me',
    'integer' => 10000,
    'float' => 0.0001,
    'flag' => false
  }

  # we use these regexes to detect different ways of extracting the default
  DefaultRegexes = [
    /[\(\[](?:def|default)?(?:\:|=)?\s*(\w+)[\)\]]/
  ]

  # we use this to scan for flag defaults
  FlagWords = {
    :true => ['true', 'yes', 'on'],
    :false => ['false', 'no', 'off']
  }

  # attempt to guess the default value for an argument
  def guess_default(args)
    # we use the description to guess
    return Defaults[args[:type]] if args[:desc].nil?
    type = args[:type] == 'flag' ? 'flag' : Kernel.const_get(args[:type].capitalize)
    test = args[:desc].strip
    guesses = []
    DefaultRegexes.each do |regex|
      guesses += test.scan(regex) if test =~ regex
    end
    if guesses.length > 0
      # we have guesses - try to understand them
      # note: at the moment we only parse the first guess
      # if we add more to DefaultRegexes we might need to
      # iterate over the guesses to see if any matches the type
      guess = guesses.first.first
      if type != 'flag'
        # easy to check if we can convert to type
        can_convert = self.convert_to(guess, type)
        if !can_convert.nil?
          # guess is the same as type, hooray!
          return can_convert
        end
      else
        # type is flag - check the guess is a flag
        if FlagWords[:true].include? guess
          return true
        elsif FlagWords[:false].include? guess
          return false
        else
          # it's not really a flag
          is_int = self.convert_to(guess, Integer)
          if !is_int.nil?
            # type is really int
            args[:type] = 'integer'
            return is_int
          end
          is_float = self.convert_to(guess, Float)
          if !is_float.nil?
            # type is really float
            args[:type] = 'integer'
            return is_float
          end
          # eliminated all other options - it's a string
          args[:type] = 'string'
          return guess
        end
      end
    else
      return Defaults[args[:type]]
    end
    guesses
  end

  # attempt to convert string guess to object of type
  # return nil on failure
  def convert_to(string, type)
    if type == Integer
      return Integer(string)
    elsif type == Float
      return Float(string)
    else
      return string
    end
  rescue ArgumentError
    return nil
  end
end
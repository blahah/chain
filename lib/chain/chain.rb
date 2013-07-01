#!/usr/bin/env ruby

require 'domain'
require 'pipeline'

class Chain

  def initialize
    # TODO: write this
  end

  def list
    Pipeline.list
  end

  def run(input)
    if Pipeline.exist? input
      Pipeline.run(input)
    elsif Pipeline.can_parse? input
      p = Pipeline.define(input)
      Pipeline.run(p)
    else
      # TODO: define a proper custom error
      raise "Invalid pipeline string."
    end
  end
  
end
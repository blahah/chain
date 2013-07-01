$LOAD_PATH.unshift(Dir.pwd)
require 'pipeline'

l = Pipeline.list()
# p l.first
# p l.first[:name]
exit()
d = Pipeline.load(l.first[:name])
# p d
p = Pipeline.new(d)
inputs = {
  :pairedreads => ['test/testl.fq', 'test/testr.fq'],
  :singlereads => 'test/singles.fq',
  :options => {}
}
p.run(inputs)
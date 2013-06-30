class Trimmomatic < Program

  #TODO: fix trimmomatic options so they can be set
  #TODO: move to execOrError

  def initialize(opts=nil)
    @path = "java -jar " + File.join(APPS_DIR, "Trimmomatic-0.30/trimmomatic-0.30.jar")
    @default = "ILLUMINACLIP:" + File.join(APPS_DIR, "Trimmomatic-0.30/adapters/TruSeq3-SE.fa") + ":2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36"
  end

  def run(inputs)
    puts "Program: Trimmomatic"
    outputp = self.trim_paired(inputs[:pairedreads]) if !inputs[:pairedreads].nil?
    outputs = self.trim_single(inputs[:singlereads]) if !inputs[:singlereads].nil?
    outputs = self.merge_singles(outputp, outputs)
    return inputs.merge(outputs) 
  end

  def trim_paired(pairedreads)
    # trim paired-end reads
    l, r = pairedreads
    puts "- trimming paired reads from #{l}:#{r} with Trimmomatic"
    lbase, rbase = File.basename(l), File.basename(r)
    cmd = "PE -phred33 #{l} #{r} t.#{lbase} u.#{lbase} t.#{rbase} u.#{rbase}"
    `#{@path} #{cmd} #{@default} &> log.log`
    `cat u* > u.all.fq`
    return ["t.#{lbase}", "t.#{rbase}", "u.all.fq"]
  end

  def trim_single(reads)
    puts "- trimming single reads from #{reads} with Trimmomatic"
    # trim single-end reads
    readsbase = File.basename(reads)
    cmd = "SE -phred33 #{reads} t.#{readsbase}"
    `#{@path} #{cmd} #{@default} &> log.log`
    return "t.#{readsbase}"  
  end

  def merge_singles(pairedreads, reads)
    # combine the unpaired and single-end
    # reads after trimming
    if pairedreads && reads && pairedreads[2]
      File.rename(reads, "tmp.#{reads}")
      `cat tmp.#{reads} #{pairedreads[3]} > #{reads} &> log.log`
      [pairedreads[2], "tmp.#{reads}"].each do |f|
        File.delete(f)
      end
    end
    return {:pairedreads => pairedreads[0..2],
            :singlereads => reads}  
  end

end

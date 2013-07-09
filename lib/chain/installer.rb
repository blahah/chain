# installer class to get and install programs
require 'uri'
require 'fileutils'

class Installer

	def self.install(file, path)
		# install file to path
		FileUtils.mv(file, path, :verbose => true, :force => true)
	end

	def self.download(url, fname=nil)
		# download and unpack file
		fname |= URI(url).path.split('/').last
	    http.request_get(url) do |resp|
	    resp.read_body do |segment|
        f.write(segment)
	    end
    end
    if fname =~ /tar|tgz/
    	`tar xvf #{fname}`
    elsif fname =~ /zip/
    	`unzip #{fname}`
    elsif fname =~ /gz/
    	`gunzip #{fname}`
    elsif fname = /bz2/
    	`bunzip2 #{fname}`
    end
   	extracted_dir = File.basename(fname,".*")
   	raise 'extraction failed' unless File.directory? extracted_dir
   	extracted_dir
	end

	def self.run(url, path)
		# install software at url to path
		e = self.download(url)
		self.install(e, path)
	end
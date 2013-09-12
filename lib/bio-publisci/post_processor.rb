module PubliSci
	class PostProcessor
		def self.process(infile,outfile,pattern)

			tmp = Tempfile.new('annot_temp')
			open(infile).each_line{|line|
				if line[pattern]
					line.scan(pattern).each{|loc|
						line.sub!(pattern,yield(loc.first))
					}
					tmp.write(line)
				else
					tmp.write(line)
				end
			}

			FileUtils.copy(tmp.path,outfile)

			outfile
		end
	end
end
module R2RDF
	module Dataset
		module Interactive
			#to be called by other classes if user input is required
			def defaults
				{
					load_from_file: false
				}
			end

			def interactive(options={})
				options = defaults.merge(options)
				qb = {}

				puts "load config from file? [y/N]"
				if gets.chomp == "y"
					#use yaml or DSL file to configure
				else
					qb[:dimensions] = dimensions()
					qb[:measures] = measures()
				end

				puts "load data from file? [y/N]"
				if gets.chomp == "y"
					#attempt to load dataset from file, ask user to resolve problems or ambiguity
				else
				end
				qb
			end

			def dimensions
				puts "Enter a list of dimensions, separated by commas"
				arr = gets.chomp.split(",")
				dims = {}

				arr.map{|dim|
					puts "What is the range of #{dim.chomp.strip}? [:coded]"
					type = gets.chomp
					type = :coded if type == ":coded" || type == ""
					dims[dim.chomp.strip] = {type: type}
				}

				dims
			end

			def measures
				puts "Enter a list of measures, separated by commas"
				arr = gets.chomp.split(",")
				meas = []

				arr.map{|m| meas << m.chomp.strip}

				meas
			end
		end
	end
end
module R2RDF
	module Reader
		class CSV
			include R2RDF::Dataset::DataCube

			def generate_n3(file, dataset_name, options={})
				@data = ::CSV.read(file)
				@options = options
				generate(measures, dimensions, codes, observation_data, observation_labels, dataset_name, options)
			end

			def dimensions
				@options[:dimensions] || [@data[0][0]]
			end

			def codes
				@options[:codes] || dimensions()
			end

			def measures
				@options[:measures] || @data[0] - dimensions()
			end

			def observation_labels
				if @options[:label_column]
					tmp = @data.dup
					tmp.shift
					tmp.map{|row|
						row[@options[:label_column]]
					}
				else
					(1..@data.size - 1).to_a
				end
			end

			def observation_data

				obs = {}
				@data[0].map{|label|
					obs[label] = []
				}
				tmp = @data.dup
				tmp.shift
				
				tmp.map{|row|
					row.each_with_index{|entry,i|
						obs[@data[0][i]] << entry
					}
				}
				obs
			end
		end
	end
end
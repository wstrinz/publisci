module R2RDF
	module Reader
		class CSV
      include R2RDF::Dataset::DataCube
			include R2RDF::Interactive

      def automatic(file=nil,dataset_name=nil,options={},interactive=true)
        #to do 
        unless file || !interactive
          puts "Input file?"
          file = gets.chomp
        end
        
        raise "CSV reader needs an input file" unless file && file.size > 0

        
        unless dataset_name
          if interactive
            dataset_name = interact("Dataset name?","#{File.basename(file).split('.').first}"){|sel| File.basename(file).split('.').first }
          else
            dataset_name = File.basename(file).split('.').first
          end
          # puts "Dataset name? [#{File.basename(file).split('.').first}]"
          # dataset_name = gets.chomp
        end
        

        categories = ::CSV.read(file)[0]


        unless options[:dimensions] || !interactive
          options[:dimensions] = Array(interact("Dimensions?",categories[0],categories))
          # dims = categories
          # puts "Which dimensions? #{dims}"
          # selection = gets.chomp
          # if selection.size > 0
          #   options[:dimensions] = selection.split(',').map(&:to_i).map{|i| dims[i]}
          # end
        end

        unless options[:measures] || !interactive
          meas = categories - ((options[:dimensions] || []) | [categories[0]])
          options[:measures] = interact("Measures?",meas,meas){|s| nil}
          options[:measures] = Array(options[:measures]) unless options[:measures] == nil
          # puts "Which measures? #{meas} "
          # selection = gets.chomp
          # if selection.size > 0
          #   options[:measures] = selection.split(',').map(&:to_i).map{|i| meas[i]}
          # end
        end

        generate_n3(file,dataset_name,options)
      end

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
module R2RDF
	module Writer
		class ARFF
			include R2RDF::Query
			include R2RDF::Parser
			include R2RDF::Analyzer

			def build_arff(relation, attributes, data, source)
				str = <<-EOS
% 1. Title: #{relation.capitalize} Database
%
% 2. Sources:
%    (a) Generated from RDF source #{source}
%     
@RELATION #{relation}

EOS

				Hash[attributes.sort].map{|attribute,type|
					str << "@ATTRIBUTE #{attribute} #{type}\n"
				}

				str << "\n@DATA\n"
				data.map { |d| str << Hash[d[1].sort].values.join(',') + "\n" }

				str
			end

			def from_turtle(turtle_file, verbose=false)
				puts "loading #{turtle_file}" if verbose
				repo = RDF::Repository.load(turtle_file)
				puts "loaded #{repo.size} statements into temporary repo" if verbose
				
				dims = get_ary(execute_from_file("dimensions.rq",repo,:graph)).flatten
				meas = get_ary(execute_from_file("measures.rq",repo,:graph)).flatten
				relation = execute_from_file("dataset.rq",repo,:graph).to_h.first[:label].to_s
				codes = execute_from_file("codes.rq",repo,:graph).to_h.map{|e| e.values.map(&:to_s)}.inject({}){|h,el|
					(h[el.first]||=[]) << el.last; h
				}

				data = observation_hash(execute_from_file("observations.rq",repo,:graph), true)
				attributes = {}
				(dims | meas).map{|component|
					attributes[component] = case recommend_range(data.map{|o| o[1][component]})
						when "xsd:int"
							"integer"
						when "xsd:double"
							"real"
						when :coded
							if dims.include? component
								"{#{codes[component].join(',')}}"
							else
								"string"
							end
						end
				}

				build_arff(relation, attributes, data, turtle_file)
			end

			def from_store(endpoint_url,variable_in=nil, variable_out=nil, verbose=false)
				raise "not implemented yet"
			end
		end
	end
end

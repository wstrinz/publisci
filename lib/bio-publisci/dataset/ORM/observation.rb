module PubliSci
		module ORM
			class Observation
				attr_accessor :data
				def initialize(data={})
					@data = data
				end

				def method_missing(name, args)
					#get entry of data hash
				end

				def respond_to_missing?(method, *)

				end
			end
	end
end
require_relative '../lib/bio-publisci.rb'

describe R2RDF::Analyzer do
	class Ana 
		include R2RDF::Analyzer
	end

	before(:all) do
		@analyzer = Ana.new
		
		@measures = ['chunkiness','deliciousness']
		@dimensions = ['producer', 'pricerange']
		@labels = %w(hormel newskies whys)
		@data = 
		{
			"producer" =>      ["hormel","newskies",  "whys"],
			"pricerange" =>    ["low",   "medium",    "nonexistant"],
			"chunkiness"=>     [1,         6,          9001],
			"deliciousness"=>  [1,         9,          6]  
		}
	end
	
	it "should run a basic validation" do
		newdata = []

		@data.keys.size.times{|i|
			obs = {}
			@data.map{|k,v|
				obs[k] = v[i]
			}
			newdata << obs
		}

		@analyzer.check_integrity(newdata, @measures, @dimensions)
	end
end
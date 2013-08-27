# require_relative '../lib/r2rdf/data_cube.rb'
# require_relative '../lib/r2rdf/generators/dataframe.rb'
# require_relative '../lib/r2rdf/r_client.rb'
# require_relative '../lib/r2rdf/r_builder.rb'
# require_relative '../lib/r2rdf/generators/csv.rb'

require_relative '../lib/bio-publisci.rb'


describe PubliSci::Dataset::DataCube do

	context "with Plain Old Ruby objects" do
		#define a temporary class to use module methods
		before(:all) do
			class Gen
				include PubliSci::Dataset::DataCube
			end

			@generator = Gen.new
			@measures = ['chunkiness','deliciousness']
			@dimensions = ['producer', 'pricerange']
			@codes = @dimensions #all dimensions coded for the tests
			@labels = %w(hormel newskies whys)
			@data =
			{
				"producer" =>      ["hormel","newskies",  "whys"],
				"pricerange" =>    ["low",   "medium",    "nonexistant"],
				"chunkiness"=>     [1,         6,          9001],
				"deliciousness"=>  [1,         9,          6]
			}
		end

		it "should have correct output according to the reference file" do

			turtle_string = @generator.generate(@measures, @dimensions, @codes,	@data, @labels, 'bacon')
			ref = IO.read(File.dirname(__FILE__) + '/turtle/bacon')
      turtle_string.should == ref
		end

		context "with missing values" do

			before(:all) do
				@missing_data = Marshal.load(Marshal.dump(@data))
				missingobs = {
					"producer" =>      "missingbacon",
					"pricerange" =>    "unknown",
					"chunkiness"=>     nil,
					"deliciousness"=>  nil,
				}
				missingobs.map{|k,v| @missing_data[k] << v}
			end

			it "skips observations with missing values by default" do
        pending('waiting for decision on null values')
				# turtle_string = @generator.generate(@measures, @dimensions, @codes,	@missing_data, @labels + ["missingbacon"], 'bacon')
				# turtle_string[/.*obsmissingbacon.*\n/].should be nil
			end

			it "includes observations with missing values if flag is set" do
				turtle_string = @generator.generate(@measures, @dimensions, @codes,	@missing_data, @labels + ["missingbacon"], 'bacon',{encode_nulls: true})
				turtle_string[/.*obsmissingbacon.*\n/].should_not be nil
			end

		end

		it 'generates prefixes' do
				prefixes = @generator.prefixes('bacon')
				prefixes.is_a?(String).should == true
			end

			it 'generates data structure definition' do
				dsd = @generator.data_structure_definition(@measures, @dimensions, @codes, "bacon")
				dsd.is_a?(String).should == true
			end

			it 'generates dataset' do
				dsd = @generator.dataset("bacon")
				dsd.is_a?(String).should == true
			end

			it 'generates component specifications' do
				components = @generator.component_specifications(@measures , @dimensions, @codes, "bacon")
				components.is_a?(Array).should == true
				components.first.is_a?(String).should == true
			end

			it 'generates dimension properties' do
				dimensions = @generator.dimension_properties(@dimensions,@codes,"bacon")
				dimensions.is_a?(Array).should == true
				dimensions.first.is_a?(String).should == true
			end

			it 'generates measure properties' do
				measures = @generator.measure_properties(@measures, "bacon")
				measures.is_a?(Array).should == true
				measures.first.is_a?(String).should == true
			end

			it 'generates observations' do
				#measures, dimensions, codes, var, observation_labels, data, options={}

				observations = @generator.observations(@measures, @dimensions, @codes, @data, @labels, "bacon")
				observations.is_a?(Array).should == true
				observations.first.is_a?(String).should == true
			end
	end

  context "under official integrity constraints" do
  	before(:all) do
  		@graph = RDF::Graph.load(File.dirname(__FILE__) + '/turtle/reference', :format => :ttl)
			@checks = {}
			Dir.foreach(File.dirname(__FILE__) + '/queries/integrity') do |file|
				if file.split('.').last == 'rq'
					@checks[file.split('.').first] = IO.read(File.dirname(__FILE__) + '/queries/integrity/' + file)
				end
			end
  	end

  	it 'obeys IC-1, has a unique dataset for each observation' do
  		SPARQL.execute(@checks['1'], @graph).first.should be_nil
  	end

  	it 'obeys IC-2, has a unique data structure definition of each dataset' do
  		SPARQL.execute(@checks['2'], @graph).first.should be_nil
  	end

  	it 'obeys IC-3, has a measure property specified for each dataset' do
  		SPARQL.execute(@checks['3'], @graph).first.should be_nil
  	end

  	it 'obeys IC-4, specifies a range for all dimensions' do
  		SPARQL.execute(@checks['4'], @graph).first.should be_nil
  	end

  	it 'obeys IC-5, every dimension with range skos:Concept must have a qb:codeList' do
  		SPARQL.execute(@checks['5'], @graph).first.should be_nil
  	end

  	it 'obeys IC-11, has a value for each dimension in every observation' do
  		SPARQL.execute(@checks['11'], @graph).first.should be_nil
  	end

  	## currently locks up. possible bug in SPARQL gem parsing?
  	## works fine as a raw query
  	# it 'obeys IC-12, has do duplicate observations' do
  	# 	SPARQL.execute(@checks['12'], @graph).first.should be_nil
  	# end

  	it 'obeys IC-14, has a value for each measure in every observation' do
  		SPARQL.execute(@checks['14'], @graph).first.should be_nil
  	end

  	it 'obeys IC-19, all codes for each codeList are included' do
  		SPARQL.execute(@checks['19_1'], @graph).first.should be_nil
  		## second query for IC-19 uses property paths that aren't as easy to
  		## convert to sparql 1.0, so for now I've left it out
  		# SPARQL.execute(@checks['19_2'], @graph).first.should be_nil
  	end
  end


		it "can set dimensions vs measures via hash" do

		end


end
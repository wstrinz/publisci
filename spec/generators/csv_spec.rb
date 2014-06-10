# require_relative '../../lib/r2rdf/data_cube.rb'
# require_relative '../../lib/r2rdf/generators/csv.rb'
require_relative '../../lib/publisci.rb'

# require 'rdf/turtle'
require 'tempfile'

describe PubliSci::Readers::CSV do

	def create_graph(turtle_string)
		f = Tempfile.new('graph')
		f.write(turtle_string)
		f.close
		graph = RDF::Graph.load(f.path, :format => :ttl)
		f.unlink
		graph
	end

	before(:each) do
		@generator = PubliSci::Readers::CSV.new
	end

	context 'with reference CSV' do
		it "should generate correct output for reference file" do
			turtle_string = @generator.generate_n3(File.dirname(__FILE__) + '/../csv/bacon.csv','bacon',{dimensions:["producer","pricerange"], label_column:0})
			ref = IO.read(File.dirname(__FILE__) + '/../turtle/bacon')
			turtle_string.should == ref
		end
	end

	it "selects first column as a coded dimension and creates measures from the rest by default" do
		turtle_string = @generator.generate_n3(File.dirname(__FILE__) + '/../csv/bacon.csv','bacon')
		graph = create_graph(turtle_string)
		qb = RDF::Vocabulary.new("http://purl.org/linked-data/cube#")

		dims = RDF::Query.execute(graph){ pattern [:dataset, qb.dimension, :dimension] }
		dims.size.should == 1
		dims.first[:dimension].to_s.should == "http://example.org/properties/producer"

		measures = RDF::Query.execute(graph){ pattern [:dataset, qb.measure, :measure] }
		measures.map{|s| s[:measure].to_s.split('/').last}.should == ["pricerange", "chunkiness", "deliciousness"]
	end

end

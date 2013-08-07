require_relative '../../lib/bio-publisci.rb'

describe PubliSci::Reader::Dataframe do

	def create_graph(turtle_string)
		f = Tempfile.new('graph')
		f.write(turtle_string)
		f.close
		graph = RDF::Graph.load(f.path, :format => :ttl)
		f.unlink
		graph
	end

  context "with r/qtl dataframe", no_travis: true do
		before(:all) do
			@r = Rserve::Connection.new
			@generator = PubliSci::Reader::Dataframe.new
			@r.eval <<-EOF
				library(qtl)
				data(listeria)
				mr = scanone(listeria,method="mr")
EOF
			@rexp = @r.eval 'mr'
			@turtle = @generator.generate_n3(@rexp,'mr')
		end

		it "generates rdf from R dataframe" do
			turtle = @generator.generate_n3(@rexp,'mr')
			turtle.is_a?(String).should be true
		end

		it "creates correct graph according to refrence file" do
			reference = IO.read(File.dirname(__FILE__) + '/../turtle/reference')
			@turtle.should eq reference
		end

		it "can optionally specify a row label" do
			@turtle = @generator.generate_n3(@rexp,'mr',{row_label:"markers"})
		end
	end



end
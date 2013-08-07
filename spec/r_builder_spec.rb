# require_relative '../lib/r2rdf/data_cube.rb'
# require_relative '../lib/r2rdf/generators/dataframe.rb'
# require_relative '../lib/r2rdf/r_client.rb'
# require_relative '../lib/r2rdf/r_builder.rb'
# require_relative '../lib/r2rdf/query_helper.rb'
# require_relative '../lib/r2rdf/generators/csv.rb'
require_relative '../lib/bio-publisci.rb'


describe PubliSci::Writer::Dataframe do

	context "when using r/qtl dataframe", no_travis: true do

		before(:all) do
			@r = Rserve::Connection.new
			@r.eval <<-EOF
				library(qtl)
				data(listeria)
				mr = scanone(listeria,method="mr")
EOF
			@builder = PubliSci::Writer::Builder.new
		end

		it "produces equivalent dataframe from rdf" #do
			#(a) problem is that builder and the @r connection are different b/c of
			#how rserve works
			# @builder.from_turtle(File.dirname(__FILE__) +'/turtle/reference', @r, 'mr', 'mo', false, false)
			# puts @r.eval('ls()').payload.to_ruby
			# @r.eval('identical(mr,mo)').to_ruby.should == true
		#end

	end
end
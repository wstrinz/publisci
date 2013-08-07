require_relative '../../lib/bio-publisci.rb'

require 'tempfile'

describe PubliSci::Reader::RCross do

  def create_graph(turtle_string)
    f = Tempfile.new('graph')
    f.write(turtle_string)
    f.close
    graph = RDF::Graph.load(f.path, :format => :ttl)
    f.unlink
    graph
  end

  context "with reduced listeria cross", no_travis: true do
    before(:all) do
      @r = Rserve::Connection.new
      @generator = PubliSci::Reader::RCross.new
      @r.eval <<-EOF
        library(qtl)
        data(listeria)

        liscopy = listeria

        for(i in 1:20)
          liscopy$geno[[i]]$data <- as.matrix(liscopy$geno[[i]]$data[1:2,])

          liscopy$pheno <- liscopy$phen[1:2,]
  EOF
    end

    it "generators output to file by default", no_travis: true do
      f=Tempfile.new('cross')
      @generator.generate_n3(@r,'liscopy',f.path,{quiet: true})
      turtle_string = IO.read("#{f.path}_structure.ttl") + IO.read("#{f.path}_1.ttl")
      graph = create_graph(turtle_string)
      graph.size.should > 0
    end

    it "can generate string output", no_travis: true #do
      # pending
      # f=Tempfile.new('cross')
      # turtle_string = @generator.generate_n3(@connection,'liscopy',f.path,{quiet: false, output: :string})

      # graph = create_graph(turtle_string)
      # graph.size.should > 0
    # end
  end

end
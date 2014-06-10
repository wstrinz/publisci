require_relative '../lib/publisci.rb'

describe PubliSci::DSL do
  include PubliSci::DSL

  before(:each) do
    PubliSci::Prov.registry.clear
    PubliSci::Metadata.registry.clear
    PubliSci::Dataset.registry.clear
  end

  context "maf files" do
    describe "set options" do
      before { PubliSci::Dataset.register_reader('.maf',PubliSci::Readers::MAF) }
      it "can change output type" do

        dat = data do
          object 'resources/maf_example.maf'
          option :output, :print
        end

        str = generate_n3
        str[/a qb:Observation/].should_not == nil
      end

      it "can output to repository" do
        dat = data do
          object 'resources/maf_example.maf'
          option :output, :print
        end

        repo = to_repository
        repo.is_a?(RDF::Repository).should be true
        repo.size.should > 0

        qry = <<-EOF
        SELECT ?observation where {
          ?observation a <http://purl.org/linked-data/cube#Observation>;
            <http://example.org/properties/Hugo_Symbol> ?node.

        }

        EOF

        sparql = SPARQL::Client.new(repo)
        sparql.query(qry).size.should > 0
      end
    end
  end

  it "can generate dataset, metadata, and provenance when given a script" do

    dat = data do
      object 'spec/csv/bacon.csv'
    end
    met = metadata do
      name "Will"
    end
    prv = provenance do
      entity :a_thing
    end

    met.should_not be nil
    prv.should_not be nil
    dat.should_not be nil

    generate_n3.size.should > 0
  end

  it "can generate dataset, metadata, and provenance when given a script" do
    ev = PubliSci::DSL::Instance.new
    dat = ev.instance_eval <<-EOF
    data do
      object 'https://raw.github.com/wstrinz/publisci/master/spec/csv/bacon.csv'
    end
    EOF
    dat.should_not be nil
    ev.generate_n3.size.should > 0
  end

  it "can set generator options" do
    dat = data do
      object 'spec/csv/bacon.csv'
      option :no_labels, true
    end

    str = generate_n3
    str[/rdfs:label "\d"/].should == nil
  end



  it "can output to in-memory repository" do
    dat = data do
      object 'spec/csv/bacon.csv'
    end

    repo = to_repository
    repo.is_a?(RDF::Repository).should be true
    repo.size.should > 0
  end

  it "can specify dimesions and measures" do
    dat = data do
      object 'spec/csv/bacon.csv'
      dimension 'producer','pricerange','chunkiness','deliciousness'
    end
    
    n3 = generate_n3
    n3["qb:measure"].should be nil
  end

  it "can output to 4store repository", no_travis: true do
    configure do |cfg|
      cfg.repository = :fourstore
    end

    dat = data do
      object 'spec/csv/bacon.csv'
    end

    repo = RDF::FourStore::Repository.new('http://localhost:8080/')
    old_size = repo.size
    repo = to_repository
    repo.is_a?(RDF::FourStore::Repository).should be true
    repo.size.should > old_size
  end

  it "can output provenance to 4store", no_travis: true do
    ev = PubliSci::Prov::DSL::Instance.new
    str = IO.read('examples/primer-full.prov')
    ev.instance_eval(str,'examples/primer-full.prov')
    ev.instance_eval <<-EOF
      configure do |cfg|
        cfg.repository = :fourstore
      end
    EOF
    repo = RDF::FourStore::Repository.new('http://localhost:8080/')
    old_size = repo.size
    repo = ev.to_repository
    repo.is_a?(RDF::FourStore::Repository).should be true
    repo.size.should > old_size
  end
end

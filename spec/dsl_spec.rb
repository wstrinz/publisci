require_relative '../lib/bio-publisci.rb'

describe PubliSci::DSL do
  include PubliSci::DSL

  before(:each) do
    PubliSci::Prov.registry.clear
    PubliSci::Metadata.registry.clear
    PubliSci::Dataset.registry.clear
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
    dat = data do
      object 'https://raw.github.com/wstrinz/bioruby-publisci/master/spec/csv/bacon.csv'
    end
    dat.should_not be nil
    generate_n3.size.should > 0
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
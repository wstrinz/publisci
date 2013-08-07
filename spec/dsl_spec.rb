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
      generate_n3
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

end
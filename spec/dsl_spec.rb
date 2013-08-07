require_relative '../lib/bio-publisci.rb'

describe PubliSci::DSL do
  include PubliSci::DSL

  before(:each) do
    PubliSci::Prov.registry.clear
    PubliSci::Metadata.registry.clear
  end

  it "can generate basic metadata as n3" do
    met = metadata do
      name "Will"
      generate_n3
    end

    prv = provenance do
      entity :a_thing
      generate_n3
    end

    met.should_not be nil
    prv.should_not be nil
  end

end
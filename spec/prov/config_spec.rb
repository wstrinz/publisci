require_relative '../../lib/bio-publisci.rb'
include PubliSci::Prov::DSL
include PubliSci::Prov

describe PubliSci::Prov::Activity do

  before(:each) do
    @evaluator = PubliSci::Prov::DSL::Singleton.new
  end

  it "can set basic config methods" do
    configure do |cfg|
      cfg.output :to_repository
    end
    settings.output.should == :to_repository
  end

  it "can configure different repository types" do
    configure do |cfg|
      cfg.repository :fourstore
    end
    a = activity :name
    a.is_a?(Activity).should be true
    r=to_repository
    a.subject.should == "http://rqtl.org/ns/activity/name"
    r.is_a?(RDF::FourStore::Repository).should be true
  end
end
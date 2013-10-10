require_relative '../../lib/publisci.rb'
include PubliSci::Prov::DSL
include PubliSci

describe PubliSci::Prov::Configuration do

  before(:each) do
    @evaluator = PubliSci::Prov::DSL::Instance.new
  end

  it "can set basic config methods" do
    configure do |cfg|
      cfg.output :to_repository
    end
    settings.output.should == :to_repository
  end

  it "can configure different repository types", no_travis: true do
    configure do |cfg|
      cfg.repository :fourstore
    end
    a = activity :name
    a.is_a?(Prov::Activity).should be true
    r=to_repository
    a.subject.should == "http://rqtl.org/ns/activity/name"
    r.is_a?(RDF::FourStore::Repository).should be true
  end
end
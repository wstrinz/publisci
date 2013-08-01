require_relative '../../lib/bio-publisci.rb'
include PubliSci::Prov::DSL
include PubliSci::Prov

describe PubliSci::Prov::Agent do
  class Ana
    include R2RDF::Analyzer
  end

  before(:each) do
    @evaluator = PubliSci::Prov::DSL::Singleton.new
  end

  it "can generate agent fields from symbol" do
    a = agent :name
    a.is_a?(Agent).should be true
    a.subject.should == "http://rqtl.org/ns/agent/name"
  end

  it "can specify fields manually" do
    a = agent :name, subject: "http://example.org/name"
    a.subject.should == "http://example.org/name"
  end

  it "can be created with a block" do
    a = agent :ag do
      subject "http://things.com/stuff"
      name "Mr Person"
    end
    a.is_a?(Agent).should be true
    a.subject.should == "http://things.com/stuff"
    a.name.should == "Mr Person"
  end

  it "can be given a type corresponding to a subclass of prov:Agent" do
    a = agent :name, type: "software"
    a.type.should == :software
    a.to_n3["prov:SoftwareAgent"].should_not be nil
  end

  it "can be created using the organization helper" do
    a = organization :group
    a.type.should == :organization
  end

  it "raises an exception when on_behalf_of does not refer to an agent" do
    a = agent :name, on_behalf_of: :other
    expect {a.on_behalf_of[0]}.to raise_error
  end

  it "lazy loads other objects, so declaration order doesn't usually matter" do
    a = agent :name, on_behalf_of: :other
    b = agent :other

    a.on_behalf_of.should == b
  end

end
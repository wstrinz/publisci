require_relative '../../lib/publisci.rb'
include PubliSci::Prov::DSL

describe PubliSci::Prov::Entity do
  before(:each) do
    @evaluator = PubliSci::Prov::DSL::Instance.new
  end

  it "can generate entity fields from symbol" do
    e = entity :name
    e.is_a?(Prov::Entity).should be true
    e.subject.should == "http://rqtl.org/ns/entity/name"
  end

  it "can specify fields manually" do
    e = entity :name, subject: "http://example.org/name"
    e.subject.should == "http://example.org/name"
  end

  it "can be created with a block" do
    e = entity :ent do
      subject "http://things.com/stuff"
      source "/somefile.txt"
    end
    e.is_a?(Prov::Entity).should be true
    e.subject.should == "http://things.com/stuff"
    e.source[0].should == "/somefile.txt"
  end

  it "raises an exception when derivation does not refer to an entity" do
    e = entity :name, derived_from: :dataset
    expect {e.derived_from[0]}.to raise_error
  end

  it "raises an exception when attribution does not refer to an agent" do
    e = entity :name, attributed_to: :person
    expect {e.attributed_to[0]}.to raise_error
  end

  it "raises an exception when generated_by does not refer to an activity" do
    e = entity :name, generated_by: :act
    expect {e.generated_by[0]}.to raise_error
  end

  it "lazy loads other objects, so declaration order doesn't usually matter" do
    e = entity :name, derived_from: :other
    f = entity :other


    e.derived_from[0].should == f
  end
end
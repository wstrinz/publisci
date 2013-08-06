require_relative '../../lib/bio-publisci.rb'

describe PubliSci::Metadata::DSL do
include PubliSci::Metadata::DSL

  before(:each) do
    PubliSci::Prov.registry.clear
  end

  it "can generate basic metadata as n3" do
    dataset 'bacon'
    title 'Bacon Data'
    description 'a dataset about bacon'
    creator 'Will'
    topic 'Delicious Bacon'
    str = generate_n3
    str[/rdfs:label "(.+)";/,1].should == "Bacon Data"
    str[/dct:creator "(.+)";/,1].should == "Will"
    str[/dct:subject "(.+)";/,1].should == "Delicious Bacon"
    str[/dct:description "(.+)";/,1].should == "a dataset about bacon"
    str[/dct:issued "(.+)"\^\^xsd:date;/,1].should == Time.now.strftime("%Y-%m-%d")
  end

  it "can add additional information about publisher" do
    dataset 'bacon'
    p = publisher do
      label "pub"
      uri "http://some-organization.com"
    end

    p.label.should == "pub"
    generate_n3[%r{dct:publisher <(.+)> .},1].should == "http://some-organization.com"
  end

  # it "can be created with a block" do
  #   a = agent :ag do
  #     subject "http://things.com/stuff"
  #     name "Mr Person"
  #   end
  #   a.is_a?(Agent).should be true
  #   a.subject.should == "http://things.com/stuff"
  #   a.name.should == "Mr Person"
  # end

  # it "can be given a type corresponding to a subclass of prov:Agent" do
  #   a = agent :name, type: "software"
  #   a.type.should == :software
  #   a.to_n3["prov:SoftwareAgent"].should_not be nil
  # end

  # it "can be created using the organization helper" do
  #   a = organization :group
  #   a.type.should == :organization
  # end

  # it "raises an exception when on_behalf_of does not refer to an agent" do
  #   a = agent :name, on_behalf_of: :other
  #   expect {a.on_behalf_of[0]}.to raise_error
  # end

  # it "lazy loads other objects, so declaration order doesn't usually matter" do
  #   a = agent :name, on_behalf_of: :other
  #   b = agent :other

  #   a.on_behalf_of.should == b
  # end

end
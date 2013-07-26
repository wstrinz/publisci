require_relative '../lib/bio-publisci.rb'

describe R2RDF::Dataset do
  context 'with a csv file' do
    before(:all) do
      @file = File.dirname(__FILE__) + '/csv/bacon.csv'
    end

    it "should load with no prompts if all details are specified" do
      turtle_string = R2RDF::Dataset.for(@file,{dimensions:["producer"],measures:["pricerange"]},false)
      (turtle_string =~ /qb:Observation/).should_not be nil
    end

    it "will request user input if not provided" do
      gen = R2RDF::Reader::CSV.new
      gen.stub(:gets).and_return('pricerange,producer')
      gen.stub(:puts)
      turtle_string = gen.automatic(@file,nil,{measures:["chunkiness"]})
      (turtle_string =~ /prop:pricerange/).should_not be nil
      (turtle_string =~ /prop:producer/).should_not be nil
    end

    it "will try to guess if told not to be interactive" do
      turtle_string = R2RDF::Dataset.for(@file,false)
      (turtle_string =~ /prop:pricerange/).should_not be nil
      (turtle_string =~ /prop:producer/).should_not be nil
    end
  end
end
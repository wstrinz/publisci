require_relative '../lib/bio-publisci.rb'

describe PubliSci::Dataset do
  it "should use sio:has_value for unknown string types" do
    turtle_string = PubliSci::Dataset.for('http://www.biostat.wisc.edu/~kbroman/D3/cistrans/data/probe_data/probe497638.json',false)
    (turtle_string =~ /hasValue/).should_not be nil
    # open('ttl.ttl','w'){|f| f.write turtle_string}
    repo = RDF::Repository.new

    f = Tempfile.new(['repo','.ttl'])
    f.write(turtle_string)
    f.close
    repo.load(f.path, :format => :ttl)
    f.unlink

    repo.size.should > 0
  end

  it "can convert arff files" do
    turtle_string = PubliSci::Dataset.for('resources/weather.numeric.arff',false)
    turtle_string.should == IO.read('spec/turtle/weather')
  end

  context 'with a csv file' do
    before(:all) do
      @file = File.dirname(__FILE__) + '/csv/bacon.csv'
    end

    it "should load with no prompts if all details are specified" do
      turtle_string = PubliSci::Dataset.for(@file,{dimensions:["producer"],measures:["pricerange"]},false)
      (turtle_string =~ /qb:Observation/).should_not be nil
    end

    it "will download remote files" do
      turtle_string = PubliSci::Dataset.for('https://raw.github.com/wstrinz/bioruby-publisci/master/spec/csv/bacon.csv',false)
      (turtle_string =~ /prop:pricerange/).should_not be nil
      (turtle_string =~ /prop:producer/).should_not be nil
    end

    it "will request user input if not provided" do
      gen = PubliSci::Readers::CSV.new
      gen.stub(:gets).and_return('pricerange,producer')
      gen.stub(:puts)
      turtle_string = gen.automatic(@file,nil,{measures:["chunkiness"]})
      (turtle_string =~ /prop:pricerange/).should_not be nil
      (turtle_string =~ /prop:producer/).should_not be nil
    end

    it "will try to guess if told not to be interactive" do
      turtle_string = PubliSci::Dataset.for(@file,false)
      (turtle_string =~ /prop:pricerange/).should_not be nil
      (turtle_string =~ /prop:producer/).should_not be nil
    end

    it "will attempt to load remote file if given URI" do
      loc = 'https://raw.github.com/wstrinz/bioruby-publisci/master/spec/csv/bacon.csv'
      turtle_string = PubliSci::Dataset.for(loc,false)
      (turtle_string =~ /prop:pricerange/).should_not be nil
      (turtle_string =~ /prop:producer/).should_not be nil
    end
  end


end
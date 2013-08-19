require_relative '../lib/bio-publisci.rb'

describe PubliSci::Writers do
  before(:each) do

  end

  it "should create reference CSV from turtle" do
    writer = PubliSci::Writers::CSV.new
    out = writer.from_turtle('spec/turtle/bacon')

    out.should == IO.read('spec/csv/bacon.csv')
  end

  it "can use store as an input" do
    writer = PubliSci::Writers::CSV.new
    repo = RDF::Repository.load('spec/turtle/bacon')
    out = writer.from_store(repo)

    out.should == IO.read('spec/csv/bacon.csv')
  end

  it "can output Wekka ARFF from turtle string" do
    writer = PubliSci::Writers::ARFF.new
    out = writer.from_turtle('spec/turtle/weather')
    out.should == IO.read('resources/weather.numeric.arff')
  end

  it "can output Wekka ARFF from a store" do
    writer = PubliSci::Writers::ARFF.new
    repo = RDF::Repository.load('spec/turtle/weather')
    out = writer.from_store(repo)

    # minor hack since metadata isn't the same
    out = out.gsub(/%.*\n/,'')

    out.should == IO.read('resources/weather.numeric.arff').gsub(/%.*\n/,'')
  end

  context "can restrict to a particular dataset" do
    it "for arff" do
      writer = PubliSci::Writers::ARFF.new
      repo = RDF::Repository.load('spec/turtle/weather')
      repo.load('spec/turtle/bacon')
      out = writer.from_store(repo, 'http://www.rqtl.org/ns/dataset/weather/dataset-weather','weather')

      out = out.gsub(/%.*\n/,'')

      out.should == IO.read('resources/weather.numeric.arff').gsub(/%.*\n/,'')
    end

    it "for csv" do
      writer = PubliSci::Writers::CSV.new
      repo = RDF::Repository.load('spec/turtle/reference')
      repo.load('spec/turtle/bacon')
      out = writer.from_store(repo,'http://www.rqtl.org/ns/dataset/bacon/dataset-bacon')

      out.should == IO.read('spec/csv/bacon.csv')
    end
  end
end
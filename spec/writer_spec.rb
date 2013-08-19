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

  it "can restrict to a particular dataset" do
    writer = PubliSci::Writers::CSV.new
    repo = RDF::Repository.load('spec/turtle/reference')
    repo.load('spec/turtle/bacon')
    out = writer.from_store(repo,'http://www.rqtl.org/ns/dataset/bacon#dataset-bacon')

    out.should == IO.read('spec/csv/bacon.csv')
  end
end
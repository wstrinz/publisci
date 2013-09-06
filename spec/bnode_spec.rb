require_relative '../lib/bio-publisci.rb'


describe "DataCube Node Generation" do

  context "with Plain Old Ruby objects" do
    #define a temporary class to use module methods
    before(:all) do
      class Gen
        include PubliSci::Dataset::DataCube
      end

      @generator = Gen.new
      @measures = ['chunkiness','deliciousness']
      @dimensions = ['producer', 'pricerange']
      @codes = @dimensions #all dimensions coded for the tests
      @labels = %w(hormel newskies whys)
      @data =
      {
        "producer" =>      ["hormel","newskies",  "whys"],
        "pricerange" =>    ["low",   "medium",    "nonexistant"],
        "chunkiness"=>     [1,         6,          9001],
        "deliciousness"=>  [1,         9,          6]
      }
    end

    it "represents nested arrays using blank nodes" do
      newdata = Hash[@data.map{|k,v| [k,v.first] }]
      newdata.keys.each{|k| newdata[k] =[[["a", "rdf:Property"],["<http://semanticscience.org/resource/SIO_000300>", newdata[k]]]] }
      observations = @generator.observations(@measures, [], [], newdata, @labels[0], "bacon")
      observations.is_a?(Array).should == true
      # puts observations.first.class
      observations.first.is_a?(String).should == true
      # puts observations
      # observations.first[%r{\[ a rdf:Property  ;\n<http://semanticscience.org/resource/SIO_000300> 1  \n \]}].should_not be nil
    end

    it "can nest arrays to some depth" do
      newdata = Hash[@data.map{|k,v| [k,v.first] }]
      newdata.keys.each{|k| 
        if ["producer","chunkiness"].include? k
          newdata[k] = [
          [
            ["a", "rdf:Property"] ,
            [
              "<http://semanticscience.org/resource/SIO_000300>", 
              [
                ["a", "rdf:absurdity"],[ 'rdf:value', newdata[k] ] 
              ]
            ]
          ]
        ]
        end
    }

      observations = @generator.observations(@measures, @dimensions, [], newdata, @labels[0], "bacon")
      observations.is_a?(Array).should == true
      observations.first.is_a?(String).should == true
      # observations.first.count('[').should == 4
      # observations.first.count(']').should == 4
      puts observations

      # observations.first[%r{\[ a rdf:Property ;\n <http://semanticscience.org/resource/SIO_000300> 1 \]}].should_not be nil
    end
  end
end
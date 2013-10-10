require_relative '../../lib/publisci.rb'

describe PubliSci::ORM do

  it "should load and save a turtle file without loss of information in old ORM" do
    pending("pending rewrite of abbreviaton method to account for base_url")
    ref = IO.read(File.dirname(__FILE__) + '/../turtle/bacon')
    cube = PubliSci::DataSet::ORM::DataCube.load(ref, {skip_metadata: true, generator_options: {label_column: 0}})
    cube.abbreviate_known(cube.to_n3).should == ref
    # cube.to_n3.should == ref
  end

  it "should load properties for Observation object" do
    ev = PubliSci::DSL::Instance.new
    r = ev.instance_eval do
      data do
        object 'spec/csv/bacon.csv'
      end

      to_repository
    end
    Spira.add_repository :default, r

    PubliSci::ORM::Observation.count.should > 0

    PubliSci::ORM::Observation.first.load_properties
    fi = PubliSci::ORM::Observation.first
    fi.chunkiness.should_not be nil
    fi.deliciousness.should_not be nil

  end

end
require_relative '../../lib/bio-publisci.rb'
include PubliSci::Prov::DSL
# include PubliSci::Prov

describe PubliSci::Prov::Model do
  it "can be loaded from" do
    ev = PubliSci::Prov::DSL::Instance.new
    r = ev.instance_eval do
      entity :datathing

      activity :process, generated: :datathing

      to_repository
    end

    Spira.add_repository :default, r
    PubliSci::Prov::Model::Entity.first.should_not be nil
  end

  context "has useful methods built in to models" do
    it "can reverse chain associated activities for agents" do
      ev = PubliSci::Prov::DSL::Instance.new

      ag = ev.instance_eval do
        agent :some_dudette
      end

      act = ev.instance_eval do
        entity :datathing

        activity :process, generated: :datathing, wasAssociatedWith: :some_dudette
      end

      r = ev.instance_eval do
        to_repository
      end


      # z= ev.instance_eval do
      #   generate_n3
      # end

      Spira.add_repository :default, r
      model_agent = PubliSci::Prov::Model::Agent.first
      ag.subject.should == model_agent.subject
      acts =  model_agent.activities
      acts.first.subject.should == act.subject
    end

    it "can dump all types for Entities" do
      ev = PubliSci::Prov::DSL::Instance.new

      qb = RDF::Vocabulary.new(RDF::URI.new('http://purl.org/linked-data/cube#'))

      r = ev.instance_eval do
        agent :some_dudette
        entity :datathing do
          has RDF.type, qb.DataSet
        end
        activity :process, generated: :datathing, wasAssociatedWith: :some_dudette

        to_repository
      end

      Spira.add_repository :default, r
      PubliSci::Prov::Model::Entity.first.all_types.should == %w{http://www.w3.org/ns/prov#Entity http://purl.org/linked-data/cube#DataSet}
    end
  end
end
require_relative '../../lib/publisci.rb'
include PubliSci::Prov::DSL

describe PubliSci::Prov::Association do
  before(:each) do
    @ev = PubliSci::Prov::DSL::Instance.new
  end

  it "can create simple associations" do
    e = @ev.entity :name
    f = @ev.agent :other
    g = @ev.activity :do_things, generated: :name, associated_with: :other
    g.associated_with[0].should == f
    @ev.generate_n3["prov:wasAssociatedWith"].size.should > 0
  end

  it "creates qualified associations when a block is passed" do
    e = @ev.entity :name
    f = @ev.agent :other
    p = @ev.plan :the_plan
    g = @ev.activity :do_things do
      generated :name
      associated_with do
        agent :other
        plan :the_plan
      end
    end
    g.associated_with.first.agent.should == f
    @ev.generate_n3["prov:wasAssociatedWith"].size.should > 0
    @ev.generate_n3["prov:qualifiedAssociation"].size.should > 0
  end

  # it "raises an exception when derivation does not refer to an entity" do
  #   e = entity :name, derived_from: :dataset
  #   expect {e.derived_from[0]}.to raise_error
  # end

  # it "raises an exception when attribution does not refer to an agent" do
  #   e = entity :name, attributed_to: :person
  #   expect {e.attributed_to[0]}.to raise_error
  # end

  # it "raises an exception when generated_by does not refer to an activity" do
  #   e = entity :name, generated_by: :act
  #   expect {e.generated_by[0]}.to raise_error
  # end

  # it "lazy loads other objects, so declaration order doesn't usually matter" do
  #   e = entity :name, derived_from: :other
  #   f = entity :other


  #   e.derived_from[0].should == f
  # end
end
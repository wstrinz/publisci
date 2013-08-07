require_relative '../../lib/bio-publisci.rb'
include PubliSci::Prov
include PubliSci::Prov::DSL

describe PubliSci::Prov::Derivation do
  before(:each) do
    @ev = PubliSci::Prov::DSL::Singleton.new
  end

  it "can create simple derivations" do
    e = @ev.entity :name
    f = @ev.entity :other, derived_from: :name
    # g = @ev.activity :do_things, generated: :name, associated_with: :other
    f.derived_from[0].should == e
    @ev.generate_n3
    @ev.generate_n3["prov:wasDerivedFrom"].size.should > 0
  end

  it "creates qualified derivations when a block is passed" do
    e = @ev.entity :name
    f = @ev.entity :other do
      derived_from :name do
        had_activity :do_things
      end
    end
    g = @ev.activity :do_things do
      generated :other
    end
    f.derived_from.first.had_activity.should == g
    # @ev.generate_n3["prov:wasAssociatedWith"].size.should > 0
    # @ev.generate_n3["prov:qualifiedAssociation"].size.should > 0
    # puts @ev.generate_n3
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
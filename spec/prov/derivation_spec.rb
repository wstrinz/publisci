require_relative '../../lib/publisci.rb'
include PubliSci::Prov::DSL

describe PubliSci::Prov::Derivation do
  before(:each) do
    @ev = PubliSci::Prov::DSL::Instance.new
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
  end
end
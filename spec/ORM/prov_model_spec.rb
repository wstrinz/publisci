require_relative '../../lib/bio-publisci.rb'
include PubliSci::Prov::DSL
include PubliSci::Prov

describe PubliSci::Prov::Model do
  it "can be loaded from" do
    ev = PubliSci::Prov::DSL::Singleton.new
    r = ev.instance_eval do
      entity :datathing

      activity :process, generated: :datathing

      to_repository
    end

    Spira.add_repository :default, r
    PubliSci::Prov::Model::Entity.first.should_not be nil
  end
end
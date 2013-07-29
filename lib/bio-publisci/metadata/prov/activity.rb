module Prov
  class Activity
    include Prov::Element

    def generated(entity=nil)
      if entity
        e = Prov.entities[entity.to_sym]
        raise "UnkownEntity #{entity}" unless e

        e.generated_by self

        (@generated ||= []) << e
      else
        @generated
      end
    end

    def associated_with(agent=nil, &block)
      if agent
        ag = Prov.agents[agent.to_sym]
        raise "UnkownAgent #{ag}" unless ag
        assoc = Association.new
        assoc.agent(ag)
        (@associated ||= []) << assoc
        Prov.register(nil,assoc)
      elsif block_given?
        assoc = Association.new
        assoc.instance_eval(&block)
        (@associated ||= []) << assoc
        Prov.register(nil,assoc)
      else
        @associated
      end
    end

    def used(entity=nil)
      if entity
        e = Prov.entities[entity.to_sym]
        raise "UnkownEntity #{entity}" unless e
        (@used ||= []) << e
      else
        @used
      end
    end
  end
end
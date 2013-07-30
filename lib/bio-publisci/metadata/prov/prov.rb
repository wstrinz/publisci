module PubliSci
  module Prov
    def self.register(name,object)
      # puts "register #{name} #{object} #{associations.size}"
      name = name.to_sym if name
      if object.is_a? Agent
        sub = :agents
      elsif object.is_a? Entity
        sub = :entities
      elsif object.is_a? Activity
        sub = :activities
      elsif object.is_a? Association
        sub = :associations
      elsif object.is_a? Plan
        sub = :plans
      else
        raise "UnknownElement: unkown object type for #{object}"
      end
      if name
        (registry[sub] ||= {})[name] = object
      else
        (registry[sub] ||= []) << object
      end
    end

    def self.registry
      @registry ||= {}
    end

    def self.run(string)
      if File.exists? string
        DSL::Singleton.new.instance_eval(IO.read(string),string)
      else
        DSL::Singleton.new.instance_eval(string)
      end
    end

    def self.agents
      registry[:agents] ||= {}
    end

    def self.entities
      registry[:entities] ||= {}
    end

    def self.activities
      registry[:activities] ||= {}
    end

    def self.associations
      registry[:associations] ||= []
    end

    def self.plans
      registry[:plans] ||= {}
    end

    def self.base_url
      @base_url ||= "http://rqtl.org/ns"
    end

    def self.base_url=(url)
      @base_url = url
    end
  end
end

module PubliSci
  class Prov
    # include PubliSci::Registry
    def self.configuration
      @config ||= Configuration.new
    end

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
        sub = object.class.to_s.split('::').last.downcase.to_sym
        # raise "UnknownElement: unkown object type for #{object}"
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
      sing =DSL::Singleton.new
      if File.exists? string
        sing.instance_eval(IO.read(string),string)
      else
        sing.instance_eval(string)
      end
      sing.output
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
      registry[:associations] ||= {}
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

    def self.prefixes
      <<-EOF
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
      EOF
    end
  end
end

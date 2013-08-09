module PubliSci
  class Prov
    extend PubliSci::Registry

    def self.configuration
      @config ||= Configuration.new
    end

    def self.symbol_for(object)
      if object.is_a? Agent
        :agents
      elsif object.is_a? Entity
        :entities
      elsif object.is_a? Activity
        :activities
      elsif object.is_a? Association
        :associations
      elsif object.is_a? Plan
        :plans
      else
        false
      end
    end


    def self.run(string)
      sing =DSL::Instance.new
      if File.exists? string
        sing.instance_eval(IO.read(string),string)
      else
        sing.instance_eval(string)
      end
      sing.output
    end

    def self.reset_settings
      Configuration.defaults.map{|k,v| configuration.send("#{k}=",v)}
      @base_url=nil
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

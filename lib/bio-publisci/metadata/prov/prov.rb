module PubliSci
  module Prov
    module Element
      def subject(s=nil)
        if s
          if s.is_a? Symbol
            raise "subject generation from symbol not yet implemented!"
          else
            @subject = s
          end
        else
          @subject ||= generate_subject
        end
      end

      def subject=(s)
        @subject = s
      end

      def __label=(l)
        @__label = l
      end

      def __label
        raise "MissingInternalLabel: no __label for #{self.inspect}" unless @__label
        @__label
      end

      #needs a better name/alias since its adding to not setting
      def set(predicate, object)
        obj = RDF::Resource(object)
        obj = RDF::Literal(object) unless obj.valid?
        ((@custom ||= {})[predicate] ||= []) << obj
      end

      def custom
        @custom
      end

      def add_custom(str)
        if custom
          custom.map{|k,v|
            pk = k.respond_to?(:to_base) ? k.to_base : k
            v.map{|vv|
              str << "\t#{pk} #{vv.to_base} ;\n"
            }
          }
        end
      end

      private
      def generate_subject
        # puts self.class == Prov::Activity
        category = case self
        when Agent
          "agent"
        when Entity
          "entity"
        when Activity
          "activity"
        when Plan
          "plan"
        else
          raise "MissingSubject: No automatic subject generation for #{self}"
        end

        "#{Prov.base_url}/#{category}/#{__label}"
      end
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

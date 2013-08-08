module PubliSci
  class Prov
    module DSL

      include PubliSci::Vocabulary

      class Instance
        include Prov::DSL

        def initialize
          Prov.registry.clear
        end
      end

      def self.included(mod)
        Prov.registry.clear
      end

      # def configure(&block)
      #   Prov.configuration.instance_eval(&block)
      # end

      def configure
        yield Prov.configuration
      end

      def named_element(name,element_class,args={},&block)
        el = element_class.new
        el.__label=name
        if block_given?
          el.instance_eval(&block)
          Prov.register(name,el)
        else
          args.keys.map{|k|
            raise "Unkown #{element_class} setting #{k}" unless try_auto_set(el,k,args[k])
          }
          Prov.register(name,el)
        end
      end

      def agent(name, args={}, &block)
        named_element(name,Prov::Agent,args,&block)
      end

      def organization(name,args={},&block)
        args[:type] = :organization
        agent(name,args,&block)
      end

      def entity(name, args={}, &block)
        named_element(name,Prov::Entity,args,&block)
      end
      alias_method :data, :entity

      def plan(name, args={}, &block)
        named_element(name,Prov::Plan,args,&block)
      end

      def activity(name,args={}, &block)
        named_element(name,Prov::Activity,args,&block)
      end

      def base_url(url)
        Prov.base_url=url
      end

      def generate_n3(abbreviate = false)
        entities = Prov.entities.values.map(&:to_n3).join
        agents = Prov.agents.values.map(&:to_n3).join
        activities = Prov.activities.values.map(&:to_n3).join
        plans = Prov.plans.values.map(&:to_n3).join
        associations = Prov.registry[:associations].values.map(&:to_n3).join if Prov.registry[:associations]
        derivations = Prov.registry[:derivation].values.map(&:to_n3).join if Prov.registry[:derivation]
        usages = Prov.registry[:usage].values.map(&:to_n3).join if Prov.registry[:usage]
        roles = Prov.registry[:role].values.map(&:to_n3).join if Prov.registry[:role]

        str = "#{entities}#{agents}#{activities}#{plans}#{associations}#{derivations}#{usages}#{roles}"

        if abbreviate
          abbreviate_known(str)
        else
          str
        end
      end

      def settings
        Prov.configuration
      end

      def return_objects
        Prov.registry
      end

      def to_repository(turtle_string=(Prov.prefixes+generate_n3))
        repo = settings.repository
        case repo
        when :in_memory
          repo = RDF::Repository.new
        when :fourstore
          repo = RDF::FourStore::Repository.new('http://localhost:8080')
        end
        f = Tempfile.new(['repo','.ttl'])
        f.write(turtle_string)
        f.close
        repo.load(f.path, :format => :ttl)
        f.unlink
        repo
      end

      def output
        cfg = Prov.configuration
        case cfg.output
        when :generate_n3
          generate_n3(cfg.abbreviate)
        when :to_repository
          raise "not implemented yet"
        end
      end

      private
      def try_auto_set(object,method,args)
        if object.methods.include? method
          object.send(method,args)
          true
        else
          false
        end
      end

      def abbreviate_known(turtle)
        ttl = turtle.dup
        %w{activity assoc agent plan entity derivation usage role}.each{|element|
          ttl.gsub!(%r{<#{Prov.base_url}/#{element}/([\w|\d]+)>}, "#{element}:" + '\1')
        }

        ttl.gsub!(%r{<http://gsocsemantic.wordpress.com/([\w|\d]+)>}, 'me:\1')
        ttl.gsub!(%r{<http://www.w3.org/ns/prov#([\w|\d]+)>}, 'prov:\1')
        ttl
      end
    end
  end
end
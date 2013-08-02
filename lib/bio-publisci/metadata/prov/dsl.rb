module PubliSci
  module Prov
    module DSL

      include PubliSci::Vocabulary

      class Singleton
        include Prov::DSL

        def initialize
          Prov.registry.clear
        end
      end

      def self.included(mod)
        Prov.registry.clear
      end

      def agent(name,args={}, &block)
        if block_given?
          a = Prov::Agent.new
          a.instance_eval(&block)
          a.__label=name
          Prov.register(name, a)
        else
          a = Prov::Agent.new
          a.__label=name
          a.subject args[:subject]
          (args.keys - [:subject]).map{|k|
            raise "Unkown agent setting #{k}" unless try_auto_set(a,k,args[k])
          }

          Prov.register(name, a)
        end
      end

      def organization(name,args={},&block)
        args[:type] = :organization
        agent(name,args,&block)
      end

      def entity(name, args={}, &block)
        if block_given?
          e = Prov::Entity.new
          e.instance_eval(&block)
          e.__label=name
          Prov.register(name, e)
        else
          # name = args.shift
          # args = Hash[*args]
          e = Prov::Entity.new

          e.__label=name
          e.subject args[:subject]
          (args.keys - [:subject]).map{|k|
            raise "Unkown entity setting #{k}" unless try_auto_set(e,k,args[k])
          }

          Prov.register(name, e)
        end
      end
      alias_method :data, :entity

      def plan(name, args={}, &block)
        if block_given?
          p = Prov::Plan.new
          p.instance_eval(&block)
          p.__label=name
          Prov.register(name, e)
        else
          p = Prov::Plan.new

          p.__label=name
          p.subject args[:subject]
          (args.keys - [:subject]).map{|k|
            raise "Unkown plan setting #{k}" unless try_auto_set(p,k,args[k])
          }


          Prov.register(name, p)
        end
      end

      def activity(name,args={}, &block)
        if block_given?
          act = Prov::Activity.new
          act.instance_eval(&block)
          act.__label=name
          Prov.register(name, act)
        else

          act = Prov::Activity.new
          act.__label=name
          act.subject args[:subject]

          (args.keys - [:subject]).map{|k|
            raise "Unkown agent setting #{k}" unless try_auto_set(act,k,args[k])
          }

          a = Prov::Activity.new

          Prov.register(name, act)
        end
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

      def return_objects
        Prov.registry
      end

      def to_repository(repo=:in_memory,turtle_string=(Prov.prefixes+generate_n3))
        case repo
        when :in_memory
          repo = RDF::Repository.new
        when :fourstore
          repo = RDF::FourStore::Repository.new('http://localhost:8080')
        end
        f = Tempfile.new('repo')
        f.write(turtle_string)
        f.close
        repo.load(f.path, :format => :ttl)
        f.unlink
        repo
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
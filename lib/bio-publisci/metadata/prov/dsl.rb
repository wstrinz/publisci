module Prov
  module DSL

    class Singleton
      include Prov::DSL
    end

    def self.included(mod)
      Prov.registry.clear
    end

    def agent(*args, &block)
      if block_given?
        a = Prov::Agent.new
        a.instance_eval(&block)
        a.__label=args[0]
        Prov.register(args[0], a)
      else
        name = args.shift
        args = Hash[*args]
        a = Prov::Agent.new

        # if args[:subject]
        #   a.subject args[:subject]
        # else
        #   #eventually generate subject from name
        # end
        raise "NoSubject: Agent #{a} was not given a subject" unless args[:subject]

        a.subject args[:subject]

        (args.keys - [:subject]).map{|k|
          raise "Unkown agent setting #{k}" unless try_auto_set(a,k,args[k])
        }

        a.__label=name

        Prov.register(name, a)
      end
    end

    def entity(*args, &block)
      if block_given?
        e = Prov::Entity.new
        e.instance_eval(&block)
        e.__label=args[0]
        Prov.register(args[0], e)
      else
        name = args.shift
        args = Hash[*args]
        e = Prov::Entity.new
        raise "NoSubject: Entity #{e} was not given a subject" unless args[:subject]

        e.subject args[:subject]
        (args.keys - [:subject]).map{|k|
          raise "Unkown entity setting #{k}" unless try_auto_set(e,k,args[k])
        }

        # e.source args[:source] if args[:source]

        e.__label=name

        Prov.register(name, e)
      end
    end
    alias_method :data, :entity

    def activity(*args, &block)
      if block_given?
        act = Prov::Activity.new
        act.instance_eval(&block)
        act.__label=args[0]
        Prov.register(args[0], act)
      else
        name = args.shift
        args = Hash[*args]

        raise "NoSubject: Activity #{a} was not given a subject" unless args[:subject]

        act.subject args[:subject]

        (args.keys - [:subject]).map{|k|
          raise "Unkown agent setting #{k}" unless try_auto_set(act,k,args[k])
        }

        a = Prov::Activity.new

        act.__label=name
        Prov.register(name, act)
        raise "has based activity creation not yet implemented"
      end
    end

    def generate_n3(abbreviate = false)
      # generate_missing

      entities = ""
      Prov.entities.map{|k,v|
        entities << "<#{v.subject}> a prov:Entity ;\n"
        entities << "\tprov:wasGeneratedBy <#{v.generated_by.subject}> ;\n"
        entities << "\trdfs:comment \"#{v.__label}\" .\n\n"
      }

      agents = ""
      Prov.agents.map{|k,v|
        agents << "<#{v.subject}> a prov:Agent"
        if v.type
          if v.type.to_sym == :software
            agents << ", prov:SoftwareAgent .\n"
          elsif v.type.to_sym == :person
            agents << ", prov:Person .\n"
          end
        else
          agents << " ;\n"
        end

        if v.name
          if v.type && v.type.to_sym == :person
            agents << "\tfoaf:givenName \"#{v.name}\" ;\n"
          else
            agents << "\tfoaf:name \"#{v.name}\" ;\n"
          end
        end

        agents << "\trdfs:comment \"#{v.__label}\" .\n\n"
      }


      activities = ""
      Prov.activities.map{|k,v|

        activities << "<#{v.subject}> a prov:Activity ;\n"

        if v.generated
          activities << "\tprov:generated "
          v.generated.map{|src|
            activities << "<#{src.subject}>, "
          }
          activities[-2]=" "
          activities[-1]=";\n"
        end

        if v.used
          activities << "\tprov:used "
          v.used.map{|used|
            activities << "<#{used.subject}>, "
          }
          activities[-2]=";"
          activities[-1]="\n"
        end

        if v.associated_with
          activities << "\tprov:wasAssociatedWith "
          v.associated_with.map{|assoc|
            activities << "<#{assoc.agent.subject}>, "
          }
          activities[-2]=" "
          activities[-1]=";\n"

          v.associated_with.map{|assoc|
            activities << "\tprov:qualifiedAssociation <#{assoc.subject}> ;\n"
          }
        end

        activities << "\trdfs:comment \"#{v.__label}\" .\n\n"
      }

      associations = ""

      Prov.associations.map{|assoc|
        associations << "<#{assoc.subject}> a prov:Association ;\n"
        associations << "\tprov:agent <#{assoc.agent.subject}> .\n\n"
      }

      str = entities + agents + activities + associations
      if abbreviate
        abbreviate_known(str)
      else
        str
      end
    end

    def return_objects
      Prov.registry
    end

    private
    def try_auto_set(object,method,args)
      if object.methods.include? method
        object.send(method,args)
      else
        false
      end
    end

    def abbreviate_known(turtle)
      ttl = turtle.dup
      %w{activity assoc agent}.each{|element|
        ttl.gsub!(%r{<#{Prov.base_url}/#{element}/([\w|\d]+)>}, "#{element}:" + '\1')
      }

      ttl.gsub!(%r{<http://gsocsemantic.wordpress.com/([\w|\d]+)>}, 'me:\1')
      ttl
    end
  end
end
module Prov
  module Element
    def subject(s=nil)
      if s
        if s.is_a? Symbol
          raise "subject generation coming soon!"
        else
          @subject = s
        end
      else
        @subject
      end
    end

    def subject=(s)
      @subject = s
    end
  end

  def self.register(name,object)
    name = name.to_sym if name
    if object.is_a? Agent
      sub = :agents
    elsif object.is_a? Entity
      sub = :entities
    elsif object.is_a? Activity
      sub = :activities
    elsif object.is_a? Association
      sub = :associations
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
      Prov::DSL::Singleton.new.instance_eval(IO.read(string),string)
    else
      Prov::DSL::Singleton.new.instance_eval(string)
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
    registry[:associations] ||= {}
  end

  def self.base_url
    @base_url ||= "http://rqtl.org/ns"
  end

  def self.base_url=(url)
    @base_url = url
  end

  class Agent
    include Prov::Element

    def type(t=nil)
      if t
        @type = t.to_sym
      else
        @type
      end
    end

    def type=(t)
      @type = t.to_sym
    end

    def name(name=nil)
      if name
        @name = name
      else
        @name
      end
    end

    def name=(name)
      @name = name
    end
  end

  class Entity
    include Prov::Element

    def source(s=nil)
      if s
        (@sources ||= []) << s
      else
        @sources
      end
    end

    def generated_by(activity=nil)
      if activity
        @generated_by = activity
      else
        @generated_by
      end
    end
  end

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

  class Association
    def subject(sub=nil)
      if sub
        @subject = sub
      else
        @subject ||= "#{Prov.base_url}/assoc/#{Time.now.nsec.to_s(32)}"
      end
    end

    def agent(agent=nil)
      if agent
        agent = Prov.agents[agent.to_sym] if agent.is_a?(String) || agent.is_a?(Symbol)
        raise "UnkownAgent #{ag}" unless agent
        # puts "Warning: overwriting agent #{@agent.subject}" if @agent
        @agent = agent
      else
        @agent
      end
    end
  end

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

        Prov.register(name, a)
      end
    end

    def entity(*args, &block)
      if block_given?
        e = Prov::Entity.new
        e.instance_eval(&block)
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

        Prov.register(name, e)
      end
    end
    alias_method :data, :entity

    def activity(*args, &block)
      if block_given?
        act = Prov::Activity.new
        act.instance_eval(&block)
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
        Prov.register(name, act)
        raise "has based activity creation not yet implemented"
      end
    end

    def generate_n3(abbreviate = false)
      generate_missing

      entities = ""
      Prov.entities.map{|k,v|
        entities << "<#{v.subject}> a prov:Entity ;\n"
        entities << "\tprov:wasGeneratedBy <#{v.generated_by.subject}> .\n\n"
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

        agents[-2] = ".\n"
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

        activities[-2] = ".\n"


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

    def generate_missing
      Prov.activities.map{|k,v|
        v.subject = "#{Prov.base_url}/activity/#{k}" unless v.subject
      }

      Prov.agents.map{|k,v|
        v.subject = "#{Prov.base_url}/agent/#{k}" unless v.subject
      }
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

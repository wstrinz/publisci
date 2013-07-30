module Prov
  class Activity
    include Prov::Element

    def generated(entity=nil)
      if entity
        if entity.is_a? Symbol
          entity = Prov.entities[entity.to_sym]
        end

        if entity.is_a? Entity
          entity.generated_by self
        end

        (@generated ||= []) << entity
      elsif @generated.is_a? Symbol
        @generated = Prov.entities[@generated]
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
      elsif @used.is_a? Symbol
        @used = Prov.entities[@used]
      else
        @used
      end
    end

    def to_n3
      str = "<#{subject}> a prov:Activity ;\n"

      if generated
        str << "\tprov:generated "
        generated.map{|src|
          str << "<#{src}>, "
        }
        str[-2]=" "
        str[-1]=";\n"
      end

      if used
        str << "\tprov:used "
        used.map{|used|
          str << "<#{used}>, "
        }
        str[-2]=";"
        str[-1]="\n"
      end

      if associated_with
        str << "\tprov:wasAssociatedWith "
        associated_with.map{|assoc|
          str << "<#{assoc.agent}>, "
        }
        str[-2]=" "
        str[-1]=";\n"

        associated_with.map{|assoc|
          str << "\tprov:qualifiedAssociation <#{assoc}> ;\n"
        }
      end

      str << "\trdfs:label \"#{__label}\" .\n\n"
    end

    def to_s
      subject
    end
  end
end
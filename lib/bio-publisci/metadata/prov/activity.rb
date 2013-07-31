module PubliSci
module Prov
  class Activity
    include Prov::Element
    class Associations < Array
      def [](index)
        if self.fetch(index).is_a? Symbol
            Prov.agents[self.fetch(index)]
        else
          self.fetch(index)
        end
      end
    end

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
        (@associated ||= Associations.new) << agent
        # Prov.register(nil,assoc)
      elsif block_given?
        assoc = Association.new
        assoc.instance_eval(&block)
        (@associated ||= Associations.new) << assoc
        Prov.register(nil,assoc)
      else
        @associated
      end
    end

    def used(entity=nil)
      if entity
        (@used ||= []) << entity
      elsif @used
        @used.map{|u| u.is_a?(Symbol) ? Prov.entities[u] : u}
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
        associated_with.map{|assoc|
          assoc = Prov.agents[assoc] if assoc.is_a?(Symbol) && Prov.agents[assoc]

          if assoc.is_a? Association
            str << "\tprov:wasAssociatedWith <#{assoc.agent}> ;\n"
            str << "\tprov:qualifiedAssociation <#{assoc}> ;\n"
          else
            str << "\tprov:wasAssociatedWith <#{assoc}> ;\n"
          end
        }
      end

      add_custom(str)

      str << "\trdfs:label \"#{__label}\" .\n\n"
    end

    def to_s
      subject
    end
  end
end
end
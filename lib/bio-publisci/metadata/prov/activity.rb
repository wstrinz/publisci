module PubliSci
module Prov
  class Activity
    include Prov::Element
    class Associations < Array
      include PubliSci::Prov::Dereferencable
      def methods
        :agents
      end
    end

    class Generations < Array
      include PubliSci::Prov::Dereferencable
      def method
        :entities
      end
    end

    class Uses < Array
      include PubliSci::Prov::Dereferencable
      def method
        :entities
      end
    end

    def generated(entity=nil)
      if entity
        if entity.is_a? Entity
          entity.generated_by self
        end
        (@generated ||= Generations.new) << entity
      else
        @generated
      end
    end

    def generated=(gen)
      @generated = gen
    end

    def associated_with(agent=nil, &block)
      if agent
        (@associated ||= Associations.new) << agent
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
        (@used ||= Uses.new) << entity
      # elsif @used
      #   @used.map{|u| u.is_a?(Symbol) ? Prov.entities[u] : u}
      else
        @used
      end
    end

    def to_n3
      str = "<#{subject}> a prov:Activity ;\n"

      if generated
        str << "\tprov:generated "
        generated.map{|src|
          src = Prov.entities[src] if src.is_a?(Symbol) && Prov.entities[src]
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
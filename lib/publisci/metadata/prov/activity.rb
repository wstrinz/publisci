module PubliSci
class Prov
  class Activity
    include Prov::Element
    class Associations < Array
      include PubliSci::Prov::Dereferencable
      def method
        :agents
      end
    end

    class Generations < Array
      include PubliSci::Prov::Dereferencable
      def method
        :entities
      end
    end

    class Usages < Array
      include PubliSci::Prov::Dereferencable
      def method
        :entities
      end
    end

    def generated(entity=nil)
      if entity.is_a? Entity
        entity.generated_by self
      elsif Prov.entities[entity]
        Prov.entities[entity].generated_by self
      end
      basic_list(:generated,:entities,Generations,entity)
    end

    def associated_with(agent=nil, &block)
      block_list(:associated,:associations,Association,Associations,agent,&block)
    end
    alias_method :wasAssociatedWith, :associated_with

    def used(entity=nil, &block)
      block_list(:use,:usages,Usage,Usages,entity, &block)
    end

    def to_n3
      str = "<#{subject}> a prov:Activity ;\n"

      if generated
        str << "\tprov:generated "
        generated.dereference.map{|src|
          str << "<#{src}>, "
        }
        str[-2]=" "
        str[-1]=";\n"
      end

      if used
        used.dereference.map{|u|
          if u.is_a? Usage
            str << "\tprov:used <#{u.entity}> ;\n"
            str << "\tprov:qualifiedUsage <#{u}> ;\n"
          else
            str << "\tprov:used <#{u}> ;\n"
          end
        }
      end

      if associated_with
        associated_with.dereference.map{|assoc|
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
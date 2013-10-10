module PubliSci
  class Prov
    class Entity
      include Prov::Element

      attr_accessor :derived_from
      attr_accessor :attributed_to

      class Derivations < Array
        include PubliSci::Prov::Dereferencable
        def method
          :entities
        end
      end


      def source(s=nil)
        if s
          (@sources ||= []) << s
        else
          @sources
        end
      end

      def generated_by(activity=nil)
        basic_keyword(:generated_by,:activities,activity)
      end

      def attributed_to(agent=nil)
        basic_keyword(:attributed_to,:agents,agent)
      end

      def derived_from(entity=nil,&block)
        block_list(:derived_from,:derivations,Derivation,Derivations,entity,&block)
      end

      def to_n3
        str = "<#{subject}> a prov:Entity ;\n"
        str << "\tprov:wasGeneratedBy <#{generated_by}> ;\n" if generated_by
        str << "\tprov:wasAttributedTo <#{attributed_to}> ;\n" if attributed_to
        if derived_from
          derived_from.size.times.each{|k|
            der = derived_from[k] # if der.is_a?(Symbol) && Prov.entities[der]

            if der.is_a? Derivation
              str << "\tprov:wasDerivedFrom <#{der.entity}> ;\n"
              str << "\tprov:qualifiedDerivation <#{der.subject}> ;\n"
            else
              str << "\tprov:wasDerivedFrom <#{der}> ;\n"
            end
          }
        end

        add_custom(str)

        str << %Q(\trdfs:label "#{__label}" .\n\n)
      end

      def to_s
        subject
      end
    end
  end
end
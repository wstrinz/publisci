module PubliSci
  module Prov
    class Entity
      class Derivations < Array
        def [](index)
          if self.fetch(index).is_a? Symbol
              Prov.entities[self.fetch(index)]
          else
            self.fetch(index)
          end
        end
      end

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
        elsif @generated_by.is_a? Symbol
          @generated_by = Prov.activities[@generated_by]
        else
          @generated_by
        end
      end

      def attributed_to(agent=nil)
        if agent
          @attributed_to = agent
        elsif @attributed_to.is_a? Symbol
          @attributed_to = Prov.agents[@attributed_to]
        else
          @attributed_to
        end
      end

      def derived_from(entity=nil,&block)
        if block_given?
          deriv = Derivation.new
          deriv.instance_eval(&block)
          (@derived_from ||= Derivations.new) << deriv
          Prov.register(nil,deriv)
        else
          if entity
            (@derived_from ||= Derivations.new) << entity
          else
            @derived_from
          end
        end
      end

      # def derived_from[](entity)
      #   if @derived_from && @derived_from[entity]
      #     if entity.is_a? Symbol
      #       Prov.entities[entity]
      #     else
      #       entity
      #     end
      #   end
      # end

      def to_n3
        str = "<#{subject}> a prov:Entity ;\n"
        str << "\tprov:wasGeneratedBy <#{generated_by}> ;\n" if generated_by
        str << "\tprov:wasAttributedTo <#{attributed_to}> ;\n" if attributed_to
        if derived_from
          derived_from.map{|der|
            der = Prov.entities[der] if der.is_a?(Symbol) && Prov.entities[der]

            if der.is_a? Derivation
              str << "\tprov:wasDerivedFrom <#{der.entity}> ;\n"
              str << "\tprov:qualifiedDerivation <#{der.subject}> ;\n"
            else
              str << "\tprov:wasDerivedFrom <#{der}> ;\n"
            end
          }
        end

        # if custom
        #   @custom.map{|k,v|
        #     str << "\t<#{k.to_s}> <#{v.to_s}> ;\n"
        #   }
        # end
        add_custom(str)

        str << %Q(\trdfs:label "#{__label}" .\n\n)
      end

      def to_s
        subject
      end
    end
  end
end
module PubliSci
  module Prov
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

      def to_n3
        str = "<#{subject}> a prov:Entity ;\n"
        str << "\tprov:wasGeneratedBy <#{generated_by}> ;\n" if generated_by
        str << "\tprov:wasAttributedTo <#{attributed_to}> ;\n" if attributed_to

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
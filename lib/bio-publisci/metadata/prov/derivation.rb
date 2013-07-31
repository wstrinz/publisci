module PubliSci
  module Prov
    class Derivation
      include PubliSci::CustomPredicate

      def subject(sub=nil)
        if sub
          @subject = sub
        else
          @subject ||= "#{Prov.base_url}/derivation/#{Time.now.nsec.to_s(32)}"
        end
      end

      def had_activity(activity=nil)
        if activity
          @had_activity = activity
        elsif @had_activity.is_a? Symbol
          @had_activity = Prov.activities[@had_activity]
        else
          @had_activity
        end
      end
      alias_method :activity, :had_activity

      def entity(entity=nil)
        if entity
          @entity = entity
        elsif @entity.is_a? Symbol
          @entity = Prov.entities[@entity]
        else
          @entity
        end
      end
      alias_method :data, :entity

      def to_n3
        str = "<#{subject}> a prov:Derivation ;\n"
        str << "\tprov:entity <#{entity}> ;\n" if entity
        str << "\tprov:hadActivity <#{had_activity}> ;\n" if had_activity

        add_custom(str)

        str[-2] = ".\n"
        str
      end

      def to_s
        subject
      end
    end
  end
end
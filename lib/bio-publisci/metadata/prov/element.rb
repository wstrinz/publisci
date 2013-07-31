module PubliSci
  module Prov
    module Element
      include PubliSci::Vocabulary
      include PubliSci::CustomPredicate

      def subject(s=nil)
        if s
          if s.is_a? Symbol
            raise "subject generation from symbol not yet implemented!"
          else
            @subject = s
          end
        else
          @subject ||= generate_subject
        end
      end

      def subject=(s)
        @subject = s
      end

      def __label=(l)
        @__label = l
      end

      def __label
        raise "MissingInternalLabel: no __label for #{self.inspect}" unless @__label
        @__label
      end

      private
      def generate_subject
        # puts self.class == Prov::Activity
        category = case self
        when Agent
          "agent"
        when Entity
          "entity"
        when Activity
          "activity"
        when Plan
          "plan"
        else
          raise "MissingSubject: No automatic subject generation for #{self}"
        end

        "#{Prov.base_url}/#{category}/#{__label}"
      end
    end
  end
end
module PubliSci
  module Prov
    module Element
      include PubliSci::Vocabulary

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

      #needs a better name/alias since its adding to not setting
      def set(predicate, object)
        predicate = RDF::Resource(predicate) if RDF::Resource(predicate).valid?
        obj = RDF::Resource(object)
        obj = RDF::Literal(object) unless obj.valid?
        ((@custom ||= {})[predicate] ||= []) << obj
      end
      alias_method :has, :set

      def custom
        @custom
      end

      def add_custom(str)
        if custom
          custom.map{|k,v|
            pk = k.respond_to?(:to_base) ? k.to_base : k
            v.map{|vv|
              str << "\t#{pk} #{vv.to_base} ;\n"
            }
          }
        end
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
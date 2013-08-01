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

      def basic_keyword(var,type,identifier=nil)
        ivar = instance_variable_get("@#{var}")

        if identifier
          instance_variable_set("@#{var}", identifier)
        elsif ivar.is_a? Symbol
          raise "NotRegistered: #{type}" unless Prov.registry[type]
          raise "Unknown#{type.capitalize}: #{ivar}" unless Prov.registry[type][ivar]
          instance_variable_set("@#{var}", Prov.registry[type][ivar])
        else
          ivar
        end
      end

      def block_list(var,type,instance_class,collection_class,name=nil,&block)
        if block_given?
          inst = instance_class.new
          inst.instance_eval(&block)
          unless instance_variable_get("@#{var}")
            instance_variable_set("@#{var}",collection_class.new)
          end
          instance_variable_get("@#{var}") << inst
          Prov.register(type,inst)
        else
          if name
            unless instance_variable_get("@#{var}")
              instance_variable_set("@#{var}",collection_class.new)
            end
            instance_variable_get("@#{var}") << name
          else
            instance_variable_get("@#{var}")
          end
        end
      end
    end
  end
end
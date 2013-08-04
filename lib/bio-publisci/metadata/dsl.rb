module R2RDF
  module Metadata
    module DSL

      def dataset(name=nil)
        set_or_get('dataset',name)
      end

      def creator(id=nil)
        set_or_get('creator',id)
      end

      def subject(sub=nil)
        add_or_get
      end

      private
      def set_or_get(var,input=nil)
        ivar = instance_variable_get("@#{var}")

        if input
          instance_variable_set("@#{var}", input)
        else
          ivar
        end
      end

      def add_or_get(var,input)
        ivar = instance_variable_get("@#{var}")

        if input
          ivar << input
        else
          instance_variable_set("@#{var}", [])
          instance_variable_get("@#{var}") << input
        end
      end
    end
  end
end
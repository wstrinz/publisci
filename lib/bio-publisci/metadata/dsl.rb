module PubliSci
  module Metadata
    module DSL

      def dataset(name=nil)
        set_or_get('dataset',name)
      end

      def creator(id=nil)
        set_or_get('creator',id)
      end

      def subject(sub=nil)
        add_or_get('subject',sub)
      end

      def description(desc=nil)
        set_or_get('description',desc)
      end

      def publisher(pub=nil)
        add_or_get('publisher',pub)
      end

      def generate_n3
        opts = {}
        %w{dataset creator subject description publisher}.each{|field|
          opts[field.to_sym] = send(field.to_sym) if send(field.to_sym)
        }
        gen = Class.new do
          include R2RDF::Metadata
        end

        gen.new.basic(opts)
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
          instance_variable_set("@#{var}", []) unless ivar
          instance_variable_get("@#{var}") << input
        else
          ivar
        end
      end
    end
  end
end
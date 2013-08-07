module PubliSci
  module Metadata
    module DSL

      def var(name=nil)
        set_or_get('var',name)
      end
      alias_method :dataset, :var

      def creator(id=nil)
        set_or_get('creator',id)
      end

      def description(desc=nil)
        set_or_get('description',desc)
      end

      def title(desc=nil)
        set_or_get('title',desc)
      end

      def topic(sub=nil)
        add_or_get('topic',sub)
      end

      def publishers(pub=nil,&block)
        if block_given?
          p = Publisher.new
          p.instance_eval(&block)
          @publishers ||= [] << p
          p
        else
          add_or_get('publishers',pub)
        end
      end
      alias_method :publisher, :publishers

      def generate_n3
        opts = {}
        %w{var creator description title}.each{|field|
          opts[field.to_sym] = send(field.to_sym) if send(field.to_sym)
        }
        opts[:subject] = topic if topic
        publishers.each{|pub|
          opts[:publishers] ||= [] << {label: pub.label, uri: pub.uri}
        } if publishers
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
          instance_variable_get("@#{var}")
        else
          ivar
        end
      end
    end
  end
end
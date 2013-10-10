module PubliSci
  class Dataset
    module DSL

      class Instance
        include Dataset::DSL

        def initialize
          Dataset.registry.clear
        end
      end

      # def interactive(value=nil)
      #   set_or_get('interactive',value)
      # end

      def object(file=nil)
        add_or_get('object',file)
      end
      alias_method :source, :object
      alias_method :input, :object

      def dimension(*args)
        if args.size == 0
          add_or_get('dimension',nil)
        else
          args.each{|arg|
            add_or_get('dimension',arg)
          }
        end
      end

      def measure(*args)
        if args.size == 0
          add_or_get('measure',nil)
        else
          args.each{|arg|
            add_or_get('measure',arg)
          }
        end
      end

      def option(opt=nil,value=nil)
        if opt == nil || value == nil
          @dataset_generator_options
        else
          (@dataset_generator_options ||= {})[opt] = value
        end
      end
      alias_method :options, :option

      def settings
        Dataset.configuration
      end

      def generate_n3
        opts = {}
        %w{dimension measure}.each{|field|
          opts["#{field}s".to_sym] = send(field.to_sym) if send(field.to_sym)
        }
        interact = settings.interactive
        if options
          opts = opts.merge(options)
        end
        object().map{|obj|
          Dataset.for(obj,opts,interact)
        }.join("\n")
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
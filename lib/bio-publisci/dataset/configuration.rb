module PubliSci
  class Dataset
    class Configuration
      def self.defaults
        {
          interactive: false,
        }
      end

      defaults.keys.each{|k|
        default = defaults[k]
        define_method(k) do |input=nil|
          var = instance_variable_get :"@#{k}"
          if var
            var
          else
            instance_variable_set :"@#{k}", default
          end

          if input
            instance_variable_set :"@#{k}", input
          end

          instance_variable_get :"@#{k}"
        end

        attr_writer k
      }
    end
  end
end

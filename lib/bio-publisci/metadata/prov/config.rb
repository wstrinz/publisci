module PubliSci
  module Prov
    class Configuration
      def self.defaults
        {
          output: :generate_n3,
          abbreviate: false,
          repository: :in_memory,
          repository_url: 'http://localhost:8080/'
        }
      end

      defaults.keys.each{|k|
        default = defaults[k]
        define_method(k) do
          var = instance_variable_get :"@#{k}"
          if var
            var
          else
            instance_variable_set :"@#{k}", default
          end
        end

        attr_writer k
      }
    end
  end
end

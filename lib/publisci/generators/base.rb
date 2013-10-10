module PubliSci
  module Generators
    module Base
      include PubliSci::Dataset::DataCube

      def write(*args)
        raise "Should be overriden"
      end
      alias_method :generate_n3, :write

      def write_to(out, string)
        out.write string
      end

      def close_output(out)
        if out.is_a? File
          out.close
        end
      end
    end
  end
end
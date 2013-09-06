module PubliSci
  module Readers
    class Base
      include PubliSci::Query
      include PubliSci::Parser
      include PubliSci::Analyzer
      include PubliSci::Interactive
      include PubliSci::Dataset::DataCube

      #should be overridden if extra processing/input is required
      def automatic(*args)
        generate_n3(args[0],Hash[*args[1..-2]])
      end

      def generate_n3(*args)
        raise "#{self} does not implement a generate_n3 method!"
      end

      def sio_identifier(type,id)
        [["a", type],["http://semanticscience.org/resource/SIO_000300",id]]
      end
    end
  end
end

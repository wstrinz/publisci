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

      def sio_value(type,value)
        [
          ["a", type],
          ["http://semanticscience.org/resource/SIO_000300",value]
        ]
      end

      def sio_attribute(type,value)
        [ 
          "http://semanticscience.org/resource/SIO_000008",
          [
            ["a", type],
            ["http://semanticscience.org/resource/SIO_000300",value]
          ]
        ]
      end
    end
  end
end

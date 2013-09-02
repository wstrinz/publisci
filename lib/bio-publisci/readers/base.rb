module PubliSci
  module Readers
    class Base
      include PubliSci::Query
      include PubliSci::Parser
      include PubliSci::Analyzer
      include PubliSci::Dataset::DataCube

      #should be overridden if extra processing/input is required
      def automatic(*args)
        generate_n3(*args)
      end

      def generate_n3(*args)
        raise "#{self} does not implement a generate_n3 method!"
      end
    end
  end
end

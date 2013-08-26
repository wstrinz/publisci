module PubliSci
  module Readers
    class Base
      include PubliSci::Query
      include PubliSci::Parser
      include PubliSci::Analyzer
      include PubliSci::Dataset::DataCube

    end
  end
end

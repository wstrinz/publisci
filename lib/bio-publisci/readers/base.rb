module PubliSci
  module Readers
    class Base
      include PubliSci::Query
      include PubliSci::Parser
      include PubliSci::Analyzer


    end
  end
end

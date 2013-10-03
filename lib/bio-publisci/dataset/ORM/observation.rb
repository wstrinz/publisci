module PubliSci
  module DataSet
    module ORM
        class Observation
          attr_accessor :data
          def initialize(data={})
            @data = data
          end
        end
    end
  end
end
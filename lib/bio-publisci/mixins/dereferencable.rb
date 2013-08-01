module PubliSci
  module Prov
    module Dereferencable
      def dereference
        self.map{|x|
          if x.is_a? Symbol
            raise "Unknown#{method.capitalize}: #{x}" unless Prov.registry[method.to_sym][x]
            Prov.registry[method.to_sym][x]
          else
            x
          end
        }
      end

      def method
        raise "must be overridden"
      end

      def [](index)
        self.dereference.fetch(index)
        # if self.fetch(index).is_a? Symbol
        #   raise "UnknownEntity: #{self.fetch(index)}" unless Prov.entities[self.fetch(index)]
        #   Prov.entities[self.fetch(index)]
        # else
        #   self.fetch(index)
        # end
      end

      def map_(&blk)
        self.dereference.map(&blk)
      end
    end
  end
end
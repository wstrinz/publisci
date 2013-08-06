module PubliSci
  module Metadata
    class Publisher

      def uri(uri=nil)
        if uri
          @uri = uri
        else
          @uri
        end
      end
      alias_method :url, :uri

      def label(label=nil)
        if label
          @label = label
        else
          @label
        end
      end
      alias_method :name, :label

    end
  end
end
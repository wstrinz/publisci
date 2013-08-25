module PubliSci
  module Writers
    class JSON < Base
      def build_json(data)
        data.values.to_json
      end

      def from_turtle(file,select_dataset=nil,shorten_url=true)
        rb = turtle_to_ruby(file,select_dataset,shorten_url)
        build_json(rb[:data])
      end

      def from_store(file,select_dataset=nil,shorten_url=true)
        build_json(repo_to_ruby(file,select_dataset,shorten_url)[:data])
      end
    end
  end
end

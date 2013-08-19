module PubliSci
  module Writers
    class CSV
      include PubliSci::Query
      include PubliSci::Parser

      def build_csv(data,components=nil)
        unless components
          components = data.values.map(&:keys).uniq
        end
        str = components.join(',') + "\n"
        data.map {|d| str << Hash[d[1].sort].values.join(',') + "\n" }
        str
      end

      def from_turtle(turtle_file, verbose=false)
        puts "loading #{turtle_file}" if verbose
        repo = RDF::Repository.load(turtle_file)
        puts "loaded #{repo.size} statements into temporary repo" if verbose

        dims = execute_from_file("dimensions.rq",repo,:graph).to_h.map{|d| d[:label].to_s}
        meas = execute_from_file("measures.rq",repo,:graph).to_h.map{|m| m[:label].to_s}
        data = observation_hash(execute_from_file("observations.rq",repo,:graph), true)
        build_csv(data, (dims | meas))
      end

      def from_store(repo,dataSet=nil, variable_out=nil, verbose=false)

        data = observation_hash(execute_from_file("observations.rq",repo,:graph,{"?dataSet}"=>"<#{dataSet}>"}), true)
        build_csv(data)
      end
    end
  end
end

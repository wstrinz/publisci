module PubliSci
  module Writers
    class CSV < Base
      def build_csv(data,components=nil)
        unless components
          components = data.values.map(&:keys).uniq
        end
        str = components.join(',') + "\n"
        data.map {|d| str << Hash[d[1]].values.join(',') + "\n" }
        str[-1]=""
        str
      end

      def from_turtle(turtle_file, verbose=false)
        puts "loading #{turtle_file}" if verbose
        repo = RDF::Repository.load(turtle_file)
        puts "loaded #{repo.size} statements into temporary repo" if verbose

        dims = dimensions(repo)
        meas = measures(repo)
        data = observations(repo)
        build_csv(data, (dims | meas))
      end

      def from_store(repo,dataSet=nil, variable_out=nil, verbose=false)
        data = observations(repo,dataSet,true)
        build_csv(data)
      end
    end
  end
end

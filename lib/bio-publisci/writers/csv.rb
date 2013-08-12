module PubliSci
  module Writer
    class CSV
      include PubliSci::Query
      include PubliSci::Parser
      # include PubliSci::Analyzer

#       def build_arff(relation, attributes, data, source)
#         str = <<-EOS
# % 1. Title: #{relation.capitalize} Database
# %
# % 2. Sources:
# %    (a) Generated from RDF source #{source}
# %
# @RELATION #{relation}

# EOS

#         Hash[attributes.sort].map{|attribute,type|
#           str << "@ATTRIBUTE #{attribute} #{type}\n"
#         }

#         str << "\n@DATA\n"
#         data.map { |d| str << Hash[d[1].sort].values.join(',') + "\n" }

#         str
#       end

      def build_csv(components,data)
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
        build_csv((dims | meas), data)
      end

      def from_store(endpoint_url,variable_in=nil, variable_out=nil, verbose=false)
        raise "not implemented yet"
      end
    end
  end
end

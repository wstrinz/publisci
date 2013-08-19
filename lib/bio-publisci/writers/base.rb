module PubliSci
  module Writers
    class Base
      include PubliSci::Query
      include PubliSci::Parser
      include PubliSci::Analyzer

      # def build_csv(data,components=nil)
      #   unless components
      #     components = data.values.map(&:keys).uniq
      #   end
      #   str = components.join(',') + "\n"
      #   data.map {|d| str << Hash[d[1]].values.join(',') + "\n" }
      #   str[-1]=""
      #   str
      # end

      def handle_input(input)
        if input.is_a? String
          if File.exist? input
            RDF::Repository.load(input)
          else
            raise "UnkownStringInput: #{input}"
          end
        elsif input.is_a? RDF::Repository
          input
        else
          raise "UnkownInput: #{input}, #{input.class}"
        end
      end

      def dimensions(input, select=:label, data_set=nil)
        repo = handle_input(input)

        if data_set
          dims = execute_from_file("dimensions.rq",repo,:graph,{"?dataSet"=>"<#{data_set}>"})
        else
          dims = execute_from_file("dimensions.rq",repo,:graph)
        end

        dims.to_h.map{|d| d[select].to_s}
      end

      def measures(input, select=:label, data_set=nil)
        repo = handle_input(input)

        if data_set
          meas = execute_from_file("measures.rq",repo,:graph,{"?dataSet"=>"<#{data_set}>"})
        else
          meas = execute_from_file("measures.rq",repo,:graph)
        end

        meas.to_h.map{|d| d[select].to_s}
      end

      def observations(input, shorten_url = true, data_set = nil)
        repo = handle_input(input)

        if data_set
          obs = execute_from_file("observations.rq",repo,:graph,{"?dataSet"=>"<#{data_set}>"})
        else
          obs = execute_from_file("observations.rq",repo,:graph)
        end

        observation_hash(obs,shorten_url)
      end

      # def from_turtle(turtle_file, verbose=false)
      #   puts "loading #{turtle_file}" if verbose
      #   repo = RDF::Repository.load(turtle_file)
      #   puts "loaded #{repo.size} statements into temporary repo" if verbose

      #   dims = execute_from_file("dimensions.rq",repo,:graph).to_h.map{|d| d[:label].to_s}
      #   meas = execute_from_file("measures.rq",repo,:graph).to_h.map{|m| m[:label].to_s}
      #   data = observation_hash(execute_from_file("observations.rq",repo,:graph), true)
      #   build_csv(data, (dims | meas))
      # end

      # def from_store(repo,dataSet=nil, variable_out=nil, verbose=false)

      #   if dataSet
      #     data = observation_hash(execute_from_file("observations.rq",repo,:graph,{"?dataSet"=>"<#{dataSet}>"}), true)
      #   else
      #     data = observation_hash(execute_from_file("observations.rq",repo,:graph), true)
      #   end
      #   build_csv(data)
      # end
    end
  end
end

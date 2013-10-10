module PubliSci
  module Writers
    class Base
      include PubliSci::Query
      include PubliSci::RDFParser
      include PubliSci::Analyzer

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

      def dimensions(input, data_set=nil, select=:label)
        repo = handle_input(input)

        if data_set
          dims = execute_from_file("dimensions.rq",repo,:graph,{"?dataSet"=>"<#{data_set}>"})
        else
          dims = execute_from_file("dimensions.rq",repo,:graph)
        end

        dims.to_h.map{|d| d[select].to_s}
      end

      def measures(input, data_set=nil, select=:label)
        repo = handle_input(input)

        if data_set
          meas = execute_from_file("measures.rq",repo,:graph,{"?dataSet"=>"<#{data_set}>"})
        else
          meas = execute_from_file("measures.rq",repo,:graph)
        end

        meas.to_h.map{|d| d[select].to_s}
      end

      def observations(input, data_set = nil, shorten_url = true)
        repo = handle_input(input)

        if data_set
          obs = execute_from_file("observations.rq",repo,:graph,{"?dataSet"=>"<#{data_set}>"})
        else
          obs = execute_from_file("observations.rq",repo,:graph)
        end

        observation_hash(obs,shorten_url)
      end

      def dataSet(input, select = :label)
        repo = handle_input(input)

        execute_from_file("dataset.rq",repo,:graph).to_h.first[select].to_s
      end

      def codes(input, data_set = nil, select = :label)
        repo = handle_input(input)

        if data_set
          codes = execute_from_file("codes.rq",repo,:graph,{"?dataSet"=>"<#{data_set}>"}).to_h
        else
          codes = execute_from_file("codes.rq",repo,:graph).to_h
        end
        codes.map{|c| c.values.map(&:to_s)}.inject({}){|h,el|
          (h[el.first]||=[]) << el.last; h
        }
      end

      def turtle_to_ruby(turtle_file, select_dataset=nil, shorten_url=true)
        repo = RDF::Repository.load(turtle_file)

        repo_to_ruby(repo,select_dataset,shorten_url)
      end

      def repo_to_ruby(repo,select_dataset=nil, shorten_url=true)
        select_dataset = dataSet(repo,:dataset) unless select_dataset
        dims = dimensions(repo,select_dataset)
        meas = measures(repo,select_dataset)
        codes = codes(repo,select_dataset)
        data = observations(repo,select_dataset,shorten_url)
        {measures: meas, dimensions: dims, coded_dimensions: codes, data: data}
      end
    end
  end
end

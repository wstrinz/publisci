module PubliSci
  module Writers
    class ARFF < Base
      # include PubliSci::Query
      # include PubliSci::Parser
      # include PubliSci::Analyzer

      def build_arff(relation, attributes, data, source)
        str = <<-EOS
% 1. Title: #{relation.capitalize} Database
%
% 2. Sources:
%    (a) Generated from RDF source #{source}
%
@RELATION #{relation}

EOS

        Hash[attributes.sort].map{|attribute,type|
          str << "@ATTRIBUTE #{attribute} #{type}\n"
        }

        str << "\n@DATA\n"
        data.map { |d| str << Hash[d[1].sort].values.join(',') + "\n" }

        str
      end

      def from_turtle(turtle_file, verbose=false)
        puts "loading #{turtle_file}" if verbose
        repo = RDF::Repository.load(turtle_file)
        puts "loaded #{repo.size} statements into temporary repo" if verbose

        dims = dimensions(repo)
        meas = measures(repo)
        data = observations(repo)

        relation = dataSet(repo)
        codes = codes(repo)

        attributes = {}

        (dims | meas).map{|component|
          attributes[component] = case recommend_range(data.map{|o| o[1][component]})
            when "xsd:int"
              "integer"
            when "xsd:double"
              "real"
            when :coded
              if dims.include? component
                "{#{codes[component].join(', ')}}"
              else
                "string"
              end
            end
        }

        build_arff(relation, attributes, data, turtle_file)
      end

      def from_store(repo, dataset=nil, title=nil, verbose=false)
        # data = observation_hash(execute_from_file("observations.rq",repo,:graph,{"%{dataSet}"=>"<#{dataSet}>"}), true)

        dims = dimensions(repo,dataset)
        meas = measures(repo,dataset)
        data = observations(repo,dataset)
        codes = codes(repo,dataset)
        attributes = {}

        (dims | meas).map{|component|
          attributes[component] = case recommend_range(data.map{|o| o[1][component]})
            when "xsd:int"
              "integer"
            when "xsd:double"
              "real"
            when :coded
              if dims.include? component
                "{#{codes[component].join(', ')}}"
              else
                "string"
              end
            end
        }

        dataset = dataSet(repo) unless dataset
        title = dataset unless title
        build_arff(title,attributes,data,dataset)
      end
    end
  end
end

module PubliSci
  module Writers
    class ARFF < Base
      include PubliSci::Query
      include PubliSci::Parser
      include PubliSci::Analyzer

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

        dims = execute_from_file("dimensions.rq",repo,:graph).to_h.map{|d| [d[:dimension].to_s, d[:label].to_s]}
        meas = execute_from_file("measures.rq",repo,:graph).to_h.map{|m| [m[:measure].to_s, m[:label].to_s]}
        relation = execute_from_file("dataset.rq",repo,:graph).to_h.first[:label].to_s
        codes = execute_from_file("codes.rq",repo,:graph).to_h
        codes = codes.map{|e| e.values.map(&:to_s)}.inject({}){|h,el|
          (h[el.first]||=[]) << el.last; h
        }

        # puts codes
        data = observation_hash(execute_from_file("observations.rq",repo,:graph), true)
        attributes = {}
        (dims | meas).map{|component|
          attributes[component[1]] = case recommend_range(data.map{|o| o[1][component[1]]})
            when "xsd:int"
              "integer"
            when "xsd:double"
              "real"
            when :coded
              if dims.include? component
                "{#{codes[component[1]].join(', ')}}"
              else
                "string"
              end
            end
        }
        build_arff(relation, attributes, data, turtle_file)
      end

      def from_store(repo,dataset=nil, verbose=false)
        data = observation_hash(execute_from_file("observations.rq",repo,:graph,{"%{dataSet}"=>"<#{dataSet}>"}), true)

        # TODO - these need to be restricted to a single dataset as with the observations
        dims = execute_from_file("dimensions.rq",repo,:graph,{"%{dataSet}"=>"<#{dataSet}>"}).to_h.map{|d| [d[:dimension].to_s, d[:label].to_s]}
        meas = execute_from_file("measures.rq",repo,:graph,{"%{dataSet}"=>"<#{dataSet}>"}).to_h.map{|m| [m[:measure].to_s, m[:label].to_s]}
        relation = execute_from_file("dataset.rq",repo,:graph,{"%{dataSet}"=>"<#{dataSet}>"}).to_h.first[:label].to_s
        codes = execute_from_file("codes.rq",repo,:graph,{"%{dataSet}"=>"<#{dataSet}>"}).to_h.map{|e| e.values.map(&:to_s)}.inject({}){|h,el|
          (h[el.first]||=[]) << el.last; h
        }
        attributes = {}
        (dims | meas).map{|component|
          attributes[component[1]] = case recommend_range(data.map{|o| o[1][component[1]]})
            when "xsd:int"
              "integer"
            when "xsd:double"
              "real"
            when :coded
              if dims.include? component
                "{#{codes[component[1]].join(',')}}"
              else
                "string"
              end
            end
        }
        build_arff(dataset,attributes,data,dataset)
       end
    end
  end
end

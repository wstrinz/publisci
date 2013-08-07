module RDF
	class Query
		class Solutions
			def to_h
				arr=[]
	    	self.map{|solution|
	    		h={}
	    		solution.map{|element|
						 	h[element[0]] = element[1]
	    		}
	    		arr << h
	    	}
	    	arr
			end
		end
	end
end

module PubliSci
  #.gsub(/^\s+/,'')
  module Query
    def vocabulary
      {
        base: RDF::Vocabulary.new('<http://www.rqtl.org/ns/#>'),
        qb:   RDF::Vocabulary.new("http://purl.org/linked-data/cube#"),
        rdf:  RDF::Vocabulary.new('http://www.w3.org/1999/02/22-rdf-syntax-ns#'),
        rdfs: RDF::Vocabulary.new('http://www.w3.org/2000/01/rdf-schema#'),
        prop: RDF::Vocabulary.new('http://www.rqtl.org/dc/properties/'),
        cs:   RDF::Vocabulary.new('http://www.rqtl.org/dc/cs')
      }
    end



    # def execute_internal(query,repo)
    #   SPARQL.execute(query,repo)
    # end

    def execute(string,store,type=:fourstore)
    	if type == :graph || store.is_a?(RDF::Graph) || store.is_a?(RDF::Repository)
				sparql = SPARQL::Client.new(store)
			elsif store.is_a? PubliSci::Store
				sparql = SPARQL::Client.new(store.url+"/sparql/")
			elsif type == :fourstore
				sparql = SPARQL::Client.new(store+"/sparql/")
      end
      sparql.query(string)
    end

    def execute_from_file(file,store,type=:fourstore)
      if File.exist?(file)
        string = IO.read(file)
      elsif File.exist?(File.dirname(__FILE__) + '/../../../resources/queries/' + file)
        string = IO.read(File.dirname(__FILE__) + '/../../../resources/queries/' + file)
      elsif File.exist?(File.dirname(__FILE__) + '/../../../resources/queries/' + file + '.rq')
        string = IO.read(File.dirname(__FILE__) + '/../../../resources/queries/' + file + '.rq')
      else
        raise "couldn't find query for #{file}"
      end
    	execute(string, store, type)
    end

#     def prefixes
#       <<-EOF
# PREFIX ns:     <http://www.rqtl.org/ns/#>
# PREFIX qb:   <http://purl.org/linked-data/cube#>
# PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX prop: <http://www.rqtl.org/dc/properties/>
# PREFIX cs:   <http://www.rqtl.org/dc/cs/>
# PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

#       EOF
#     end

    def property_values(var, property)
      str = prefixes
      str << <<-EOS
SELECT ?val WHERE {
  ?obs qb:dataSet ns:dataset-#{var} ;
      prop:#{property} ?val ;
}
      EOS
      str
    end

    def row_names(var)
      str = prefixes
      str << <<-EOS
SELECT ?label WHERE {
  ?obs qb:dataSet ns:dataset-#{var} ;
       prop:refRow ?row .
  ?row skos:prefLabel ?label .
}
      EOS
    end

    # Currently will say "___ Component", needs further parsing
    def property_names(var)
      str = prefixes
      str << <<-EOS
SELECT DISTINCT ?label WHERE {
  ns:dsd-#{var} qb:component ?c .
  ?c rdfs:label ?label
}
      EOS
    end

  end

  class QueryHelper
    include PubliSci::Query
  end
end
module R2RDF
	module Parser
		def create_graph(string)
			f = Tempfile.new('graph')
			f.write(string)
			f.close
			graph = RDF::Graph.load(f.path, :format => :ttl)
			f.unlink
			graph
		end

		def get_ary(query_results,method='to_s')
      query_results.map{|solution|
        solution.to_a.map{|entry|
          if entry.last.respond_to? method
	          entry.last.send(method)
	        else
	        	entry.last.to_s
	        end
        }
      }
    end

    def get_hashes(query_results,method=nil)
    	arr=[]
    	query_results.map{|solution|
    		h={}
    		solution.map{|element|
					if method && element[1].respond_to?(method)
					 	h[element[0]] = element[1].send(method)
					else
					 	h[element[0]] = element[1]
					end
    		}
    		arr << h
    	}
    	arr
    end

    def observation_hash(query_results,shorten_uris=false,method='to_s')
    	h={}
    	query_results.map{|sol|
    		(h[sol[:observation].to_s] ||= {})[sol[:property].to_s] = sol[:value].to_s
    	}

    	if shorten_uris
	    	newh= {}
	    	h.map{|k,v| 
	    		newh[strip_uri(k)] ||= {}
	    		v.map{|kk,vv| 
	    			newh[strip_uri(k)][strip_uri(kk)] = strip_uri(vv)
	    		}
	    	}
	    	newh
	    else
	    	h
	    end
    end

    def strip_uri(uri)
    	uri.to_s.split('/').last.split('#').last
    end
	end
end
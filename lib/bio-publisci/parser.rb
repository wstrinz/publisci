module PubliSci
	module Parser

    def is_uri?(obj)
      RDF::Resource(obj).valid?
    end

    def sanitize(array)
      #remove spaces and other special characters
      array = Array(array)
      processed = []
      array.map{|entry|
        if entry.is_a? String
          if is_uri? entry
            processed << entry.gsub(/[\s]/,'_')
          else
            processed << entry.gsub(/[\s]/,'_')
          end
        else
          processed << entry
        end
      }
      processed
    end

    def sanitize_hash(h)
      mappings = {}
      h.keys.map{|k|
        if(k.is_a? String)
          mappings[k] = k.gsub(' ','_')
        end
      }

      h.keys.map{|k|
        h[mappings[k]] = h.delete(k) if mappings[k]
      }

      h
    end

		def load_string(string,repo=RDF::Repository.new)
			f = Tempfile.new('repo')
			f.write(string)
			f.close
			repo.load(f.path, :format => :ttl)
			f.unlink
			repo
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

    def to_resource(obj, options={})
      if obj.is_a? String

        if is_uri? obj
          obj = RDF::Resource(obj).to_base unless obj[/\w+:\w/]
        else

          #TODO decide the right way to handle missing values, since RDF has no null
          #probably throw an error here since a missing resource is a bigger problem
          obj = "rdf:nil" if obj.empty?
          obj=  obj.to_s.gsub(' ','_')
        end

        obj
        #TODO  remove special characters (faster) as well (eg '?')

      elsif obj == nil && options[:encode_nulls]
        'rdf:nil'
      elsif obj.is_a? Numeric
        #resources cannot be referred to purely by integer (?)
        "n"+obj.to_s
      else
        obj
      end
    end

    def to_literal(obj, options={})
      if obj.is_a? String
        # Depressing that there's no more elegant way to check if a string is
        # a number...
        if val = Integer(obj) rescue nil
          val
        elsif val = Float(obj) rescue nil
          val
        else
          '"'+obj+'"'
        end
      elsif obj == nil && options[:encode_nulls]
        #TODO decide the right way to handle missing values, since RDF has no null
        'rdf:nil'
      else
        obj
      end
    end

    def is_complex?(obj)
      obj.is_a? Array
    end

    def add_node(n,str="")

      raise "need index or identifier to generate blank nodes" unless n
      raise "need base string or blank string for blank node" unless str.is_a? String
      if str["node"]
        ret = str[0..-2] + "/#{n}" + ">"
        ret
        # str[0..-2] + "/#{n}" + ">"
      else
        "<node/#{n}>"
      end
    end

    def encode_value(obj,options={}, node_index=nil, node_str = "")
      if RDF::Resource(obj).valid?
        to_resource(obj,options)
      elsif obj && obj.is_a?(String) && (obj[0]=="<" && obj[-1] = ">")
        obj
      elsif obj.is_a?(Array)        
        node_str = add_node(node_index,node_str)
        ["#{node_str}" ] + [bnode_value(obj, node_index, node_str, options)]
      else
        to_literal(obj,options)
      end
    end

    def bnode_value(obj, node_index, node_str, options)
      # TODO - Implement proper recursion
      # TODO - check if object is "a" (rdf:type) => or convert rdf:type to "a"
      str = ""
      subnodes = []
      if obj.is_a?(Array) && obj.size == 2
        if obj[0].is_a?(String)
          if is_complex?(obj[1])
            str << "#{to_resource(obj[0])} #{add_node(node_index,node_str)} . \n"            
            subnodes << encode_value(obj[1], options, node_index, node_str)
          else
            str << "#{to_resource(obj[0])} #{encode_value(obj[1], options, node_index, node_str)} "
          end
        elsif obj[0].is_a?(Array) && obj[1].is_a?(Array)
          newnode = add_node(0,node_str)
          v1 = bnode_value(obj[0], 0, node_str, options)
          v2 = bnode_value(obj[1], 1, node_str, options)

          if v1.is_a? Array
            subnodes << v1
            v1 = nil
          end

          if v2.is_a? Array
            subnodes << v2
            v2 = nil
          end

          if v1
            str << "#{v1} ;"
          end

          str << "\n#{v2} .\n" if v2
        end
      else
        raise "Invalid Structured value: #{obj}"
      end

      if subnodes.size > 0 
        [str, subnodes.flatten].flatten
      else
        str
      end
    end

    def turtle_indent(turtle_str)
      tabs = 0
      turtle_str.split("\n").map{|str|
        case str[-1]
        when "."
          last_tabs = tabs
          tabs = 0
          ("  " * last_tabs) + str
        when ";"
          last_tabs = tabs
          tabs = 1 if tabs == 0
          ("  " * last_tabs) + str
        else
          last_tabs = tabs
          if str.size < 2
            tabs = 0
          else
            tabs += 1
          end
          ("  " * last_tabs) + str
        end
      }.join("\n")

    end

    def strip_uri(uri)
      uri = uri.to_s.dup
      uri[-1] = '' if uri[-1] == '>'
      uri.to_s.split('/').last.split('#').last
    end

    def strip_prefixes(string)
      string.to_s.split(':').last
    end

	end
end
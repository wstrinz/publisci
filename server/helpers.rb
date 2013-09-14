class PubliSciServer < Sinatra::Base

  helpers do

    def h(str)
      CGI::escapeHTML(str.to_s)
    end

    def create_repository(type,uri)
      if type == "in_memory"
        flash[:notice] = "#{type} repository created!"
        RDF::Repository.new
      elsif type == "4store"
        unless RDF::URI(uri).valid?
          flash[:notice] = "Need a valid URI for a FourStore repository"
          nil
        end

        flash[:notice] = "#{type} repository created!"
        RDF::FourStore::Repository.new(uri)
      else
        raise "UnkownTypeForSomeReason?: #{type}"
      end
    end

    def clear_repository
      raise "not implemented yet"
    end

    def import_rdf(input,type)
      if type == :file

        raise "file type #{input.read}"
      else
        oldsize = settings.repository.size
        read = RDF::Reader.for(type.to_sym)
        read = read.new(input)
        settings.repository << read
        flash.now[:notice] = "#{settings.repository.size - oldsize} triples imported"
        # raise "string type #{type}"
      end
    end

    def query_repository(query,format_result = true)
      repo = settings.repository
      if repo.is_a? RDF::FourStore::Repository
        sols = SPARQL::Client.new("#{settings.repository.uri}/sparql/").query(query)
      elsif repo.is_a? RDF::Repository
        sols = SPARQL::Client.new(settings.repository).query(query)
      else
        raise "Unrecognized Repository: #{settings.repository.class}"
      end

      if format_result
        str = '<table border="1">'
        sols.map{|solution|
          str << "<tr>"
          solution.bindings.map{|bind,result|
            str << "<td>" + CGI.escapeHTML("#{bind}:  #{result.to_s}") + "</td>"
          }
          str << "</tr>"
        }
        str << "</table>"
        
        str
      else
        sols
      end

    end
  end
end
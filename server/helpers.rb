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

    def query_repository(query)
      case settings.repository.class
      when RDF::FourStore::Repository
        SPARQL::Client.new("#{settings.repository.uri}/sparql/").query(query)
      when RDF::Repository
        SPARQL::Client.new(settings.repository).query(query)
      else
        raise "Unrecognized Repository: #{settings.repository.class}"
      end
    end
  end
end
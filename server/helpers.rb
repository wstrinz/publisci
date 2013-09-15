class PubliSciServer < Sinatra::Base

  helpers do

    def h(str)
      CGI::escapeHTML(str.to_s)
    end

    CONTENT_TYPES={'xml' => 'text/xml','json' => 'application/json'}

    def content_for(data,fallback=:to_html,format=(params[:format] || request.accept))
        if params[:format]
          format = CONTENT_TYPES[format]
        else
          format = format.first
        end
        if CONTENT_TYPES.values.include? format
          content_type format #, :charset => 'utf-8'
        end

        case format.to_s
        when 'text/xml'
          data.to_xml
        when 'application/json'
          data.to_json
        else
          if data.respond_to? fallback
            data.send(fallback)
          else
            data.to_s
          end
        end
    end

    def content_response(haml_page,content=:no_content)
      if request.accept? 'text/html'
        haml :"#{haml_page}"
      else
        content
      end
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

    def example_query
      "SELECT * WHERE {?s ?p ?o}"
    end

    def import_rdf(input,type)
      if type == :file
        oldsize = settings.repository.size
        settings.repository.load(input.path)
        "#{settings.repository.size - oldsize} triples imported"
      else
        oldsize = settings.repository.size
        read = RDF::Reader.for(type.to_sym)
        read = read.new(input)
        settings.repository << read
        "#{settings.repository.size - oldsize} triples imported"
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

     sols

    end
  end
end
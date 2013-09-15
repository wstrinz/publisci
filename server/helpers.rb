class PubliSciServer < Sinatra::Base

  helpers do

    def h(str)
      CGI::escapeHTML(str.to_s)
    end

    def format_ttl(str)
      str.gsub("\n","\n<br>").gsub('<br>     ','<br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ').gsub('<br>   ','<br>&nbsp; &nbsp; &nbsp; ')
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

    def content_response(html_resp,content=:no_content)
      if request.accept? 'text/html'
        if html_resp.is_a? Symbol
          haml html_resp
        else
          html_resp
        end
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
      repo = settings.repository
      if repo.is_a? RDF::FourStore::Repository
      passwd = settings.sudo_pass
      raise "need sudo password set to clear 4store" unless passwd
      `echo #{passwd} | sudo -S killall 4s-backend`
      `echo #{passwd} | sudo -S killall 4s-httpd`
      `echo #{passwd} | sudo -S 4s-backend-setup test`
      `echo #{passwd} | sudo -S 4s-backend test`
      `echo #{passwd} | sudo -S 4s-httpd -U test`

      else
        repo.clear
      end
    end

    def example_query
      "SELECT * WHERE {?s ?p ?o} LIMIT 10"
    end

    def example_dsl
      <<-EOF
data do
  object "https://raw.github.com/wstrinz/bioruby-publisci/master/spec/csv/bacon.csv"

  object "https://raw.github.com/wstrinz/bioruby-publisci/master/resources/weather.numeric.arff"
end
      EOF
    end

    def load_dsl(script)
      ev = PubliSci::DSL::Instance.new
      begin
        ev.instance_eval(script)
      rescue Exception => e
        raise "Caught error in eval #{e} #{e.backtrace}"
      end
      
      import_rdf(ev.instance_eval("generate_n3"),:ttl)
    end

    def import_rdf(input,type)
      if input.is_a?(File) || input.is_a?(Tempfile)
        f = Tempfile.new(['',".#{type}"])
        begin
          f.write(input.read)
          f.close
          oldsize = settings.repository.size
          settings.repository.load(f.path, format: type)
        ensure
          f.unlink
        end
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
class PubliSciServer < Sinatra::Base

  helpers do

    def h(str)
      CGI::escapeHTML(str.to_s)
    end

    def format_ttl(str)
      #TODO make this actually work right
      str.gsub("\n","\n<br>").gsub('<br>     ','<br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ').gsub('<br>   ','<br>&nbsp; &nbsp; &nbsp; ')
    end

    def self.configure_server(opts)
      set :port, opts[:port].to_i if opts[:port]
      set :bind, opts[:bind] if opts[:bind]
      if opts[:type]
        if opts[:type] == "fourstore"
          uri = opts[:uri] || 'http://localhost:80802'
          set :repository, RDF::FourStore::Repository.new(uri.dup)
        else
          set :repository, RDF::Repository.new
        end
      else
        set :repository, RDF::Repository.new
      end
    end

    def print_usage
      str = puts <<-EOF
Bio-PubliSci Server Interface

Description: Start the server and point your browser to localhost:4567

Usage: bio-publisci-server [options]

      EOF
    end

    CONTENT_TYPES={'xml' => 'text/xml','json' => 'application/json','ttl' => 'text/n3'}

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

    def rdf_content_for(data,fallback=:to_html,format=(params[:format] || request.accept))
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
        data.to_rdfxml
      when 'application/rdf+xml'
        data.to_rdfxml
      when 'application/json'
        data.dump(:jsonld, :standard_prefixes => true)
      when 'text/n3'
        data.to_ttl
      else
        if data.respond_to? fallback
          data.send(fallback)
        else
          data.to_s
        end
      end
    end

    def content_response(html_resp,content=:no_content)
      if !CONTENT_TYPES.keys.include?(params[:format].to_s) and request.accept? 'text/html'
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

    def default_prefixes
      <<-EOF
PREFIX qb:    <http://purl.org/linked-data/cube#>
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl:   <http://www.w3.org/2002/07/owl#>
PREFIX skos:  <http://www.w3.org/2004/02/skos/core#>

      EOF
    end

    def example_query
      default_prefixes +
      <<-EOF
SELECT * WHERE {
  ?s ?p ?o
} LIMIT 10
      EOF
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
module R2RDF
  module Writer
    module Dataframe

    def framestring(name,vectors)
      framestr = "#{name} = data.frame("
      vectors.map{ |k,v| framestr << k + '=' + k +','}
      framestr[-1] = ')'
      framestr
    end

    def get_vectors(variable_name, helper, repo)
      column_names = helper.get_ary(helper.execute(helper.property_names(variable_name), repo)).flatten.map{|n| n.gsub(' Component','')}
      vectors = {}
      column_names.map{|n|
        vectors[n] = helper.get_ary(helper.execute(helper.property_values(variable_name,n),repo),'to_f').flatten unless n == "refRow"
      }
      vectors
    end

    def create_dataframe(name, connection, rows, vectors)
      connection.assign('rows', rows)
      vectors.map{ |k,v|
        connection.assign(k,v)
      }
      connection.eval(framestring(name,vectors))
      connection.eval("row.names(#{name}) <- rows")
      connection.eval(name)
    end

    def save_workspace(connection, loc)
      connection.eval "save.image(#{loc})"
    end

    def get_rownames(variable, helper, repo)
      rows = helper.get_ary(helper.execute(helper.row_names(variable), repo)).flatten
    end

  end

  class Builder
    include R2RDF::Writer::Dataframe


    def from_turtle(turtle_file, connection, variable_in=nil, variable_out=nil, verbose=true, save=true)
      unless variable_in && variable_out
        puts "no variable specified. Simple inference coming soon" if verbose
        return
      end
      puts "loading #{turtle_file}" if verbose
      repo = RDF::Repository.load(turtle_file)
      puts "loaded #{repo.size} statements into temporary repo" if verbose
      # connection = Rserve::Connection.new
      query = R2RDF::QueryHelper.new
      rows = get_rownames(variable_in, query, repo)
      puts "frame has #{rows.size} rows" if verbose

      vectors = get_vectors(variable_in, query, repo)
      puts "got vectors of size #{vectors.first.last.size}" if verbose && vectors.first

      create_dataframe(variable_out, connection, rows, vectors)
      save_workspace(connection, connection.eval('getwd()').to_ruby) if save
    end

    def from_store(endpoint_url,connection,variable_in=nil, variable_out=nil, verbose=true, save=true)
      unless variable_in && variable_out
        puts "no variable specified. Simple inference coming soon" if verbose
        return
      end
      puts "connecting to endpoint at #{endpoint_url}" if verbose
      sparql = SPARQL::Client.new(endpoint_url)
      # client = R2RDF::Client.new
      query = R2RDF::QueryHelper.new

      rows = query.get_ary(sparql.query(query.row_names(variable_in))).flatten

    end

    end
  end
end
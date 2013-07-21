require 'rserve'
require 'rdf/4store'
Dir[File.dirname(__FILE__) + '/vocabs/*.rb'].each {|file| require file }

class QTL2RDF

  attr_accessor :port_4s

  def initialize(dir='.')
    @dir = File.absolute_path(dir)
    @R = Rserve::Connection.new()
    if File.exist?(dir + "/.RData")
      # puts "loading workspace #{dir}/.RData"
      @R.eval("load('#{dir}/.RData')")
    end

    if File.exist?(dir + "/.Rhistory")
      # puts "loading history #{dir}/.Rhistory"
      @R.eval("loadhistory('#{dir}/.Rhistory')")
    end

    @port_4s = 8080
  end

  def load_workspace(dir=@dir,file='.RData')
    path = File.join(File.absolute_path(dir),file)
      if File.exist?(path)
        # puts "loading workspace #{dir}/.RData"
        @R.eval("load('#{path}')")
      else
        puts "Couldn't find #{path}"
      end
  end

  def load_history(dir=@dir,file='.Rhistory')
    path = File.join(File.absolute_path(dir),file)
    if File.exist?(path)
      # puts "loading history #{dir}/.Rhistory"
      @R.eval("loadhistory('#{path}')")
    else
      puts "Couldn't find #{path}"
    end
  end

  def dump_dataframe(var)
    h = {}
    h[var] = {"attr" => {}, "rows"=>{}}

    x = @R.eval(var)

    x.attr.payload.keys.map{ |a|
      h[var]["attr"][a] = x.attr.payload[a].to_ruby
    }

    rownames = x.attr.payload["row.names"].to_ruby
    colnames = x.payload.keys
    rownames.each_with_index.map{ |row,i|
      rh = {}
      colnames.map{ |col|
        rh[col] = x.payload[col].to_a[i].to_f
      }
      h[var]["rows"][row] = rh
    }

    h
  end

  def dump(var)
    x = @R.eval(var)
    if x.attr
      # if x.attr.payload["class"].to_a.include? 'data.frame'
        dump_dataframe var
      # end
    else
      if x.list?
        type = x.payload.class.to_s.split("::").last # seems hacky, but probably only temporary
        value = x.payload.map(&:payload).flatten
      elsif x.payload.size == 1
        type = x.class.to_s.split("::").last 
        value = x.payload.first
      else
        type = x.class.to_s.split("::").last 
        value = x.payload
      end
      {var => {"attr"=>{"class" => type}, :value => value}}
    end
  end

  def triples_for(h)
    statements = []
    base_n = RDF::Node.new
    attr_n = RDF::Node.new
    vocab = RDF::Vocabulary.new('http://www.placeholder.com/rqtl#')
    base_uri = RDF::URI.new('http://www.placeholder.com/')
    var = h.keys.first

    statements << RDF::Statement.new(base_n, RDF::DC.title, RDF::Literal.new(var))

    if h[var].is_a? Hash
      if(h[var]["attr"])
        statements << RDF::Statement.new(base_n, vocab.attributes, attr_n)
        h[var]["attr"].map{ |k,v| statements << RDF::Statement.new(attr_n, vocab[k], RDF::Literal.new(v)) }
      end

      if h[var]["rows"]
        h[var]["rows"].map{ |k,v|
          row_uri = base_uri.join("row#{k}")
          statements << RDF::Statement.new(row_uri, vocab.row_of, base_n)
          statements << RDF::Statement.new(row_uri, RDF::DC.title, k)
          num = 1 # maybe container support exists in RDF.rb?
          v.map { |j,u|
            n = RDF::Node.new
            statements << RDF::Statement.new(n, vocab.entry_of, row_uri)
            statements << RDF::Statement.new(n, RDF::DC.title, j)
            statements << RDF::Statement.new(n, RDF::DC.title, j)
            statements << RDF::Statement.new(n, vocab["_#{num}"], RDF::Literal.new(u))
            num += 1
          }
        }
      end

      if h[var].has_key? :value        
        statements << RDF::Statement.new(base_n, vocab.has_value, RDF::Literal.new(h[var][:value]))
      end
    else
      statements << RDF::Statement.new(base_n, vocab.has_value, RDF::Literal.new(h[var]))
    end
    statements
  end

  #get n3 for a dataframe using datacube vocabulary
  #still needs range for measures and dimensions, sdmx-dimension equivalent for rows
  def n3_for(h)
    str = <<-EOF
@prefix : <http://www.rqtl.org/ns/#> .
@prefix qb: <http://purl.org/linked-data/cube#> .
@prefix rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix prop: <http://www.rqtl.org/dc/properties/> .
@prefix cs: <http://www.rqtl.org/dc/cs/> .

    EOF
    #@prefix sdmx-measure: <http://purl.org/linked-data/sdmx/2009/measure#>
    var = h.keys.first
    names = h[var]["attr"]["names"]

    #generate data structure definition
    str << ":dsd-#{var} a qb:DataStructureDefinition ;\n"
    str << "\tqb:component cs:refRow ,\n"
    names.map{ |n|
      str << "\t\tcs:#{n} ,\n\n"
    }
    str[-3]="."

    #generate component specifications
    str << "cs:refRow a qb:ComponentSpecification ;\n\trdfs:label \"Component Specification for Row\" ;\n\tqb:dimension prop:refRow .\n\n"
    names.map{ |n|
      str << "cs:#{n} a qb:ComponentSpecification ;\n\trdfs:label \"Component Specification for #{n}\" ;\n\tqb:measure prop:#{n} .\n\n"
    }

    #generate dataset definition
    str << ":dataset-#{var} a qb:DataSet ;\n\trdfs:label \"#{var}\"@en ;\n\tqb:structure :dsd-#{var} .\n\n"

    #add DimensionProperty for row
    str << <<-EOF
:refRow a rdf:Property, qb:DimensionProperty ;
\trdfs:label "Row"@en .

    EOF

    #generate MeasureProperties
    names.map{ |n|
      str << ":#{n} a rdf:Property, qb:MeasureProperty ;\n\trdfs:label \"#{n}\"@en .\n\n"
    }

    #add observations
    h[var]["rows"].map{|k,v|
      str << ":obs#{k} a qb:Observation ;\n\tqb:dataSet :dataset-#{var} ;\n\tprop:refRow :#{k} ;\n"
      v.map{|l,w|
        str << "\tprop:#{l} #{w} ;\n"
      }
      str << "\t.\n\n"
    }

    #add row property definitions
    h[var]["rows"].map{|k,v|
      str << ":#{k} a prop:refRow ;\n\trdfs:label \"#{k}\" .\n\n"
    }

    str
  end

  def statements_for(string,type=:turtle)
    statements = []
    RDF::Reader.for(:turtle).new(string) do |reader|
      reader.each_statement do |statement|
        # puts statement.inspect
        statements << statement
      end
    end
    statements
  end

  def turtletype_for(value)
    #use for providing ranges to better define data (later)
  end

  def load_statements(statements)
    #maybe a better way than inserting statements one at a time?
    repo = RDF::FourStore::Repository.new("http://localhost:#{@port_4s}")
    statements.each{|s| repo.insert(s)}
  end

  def to_store(var, parse_type=:turtle)
    load_statements(triples_for(dump(var))) if parse_type==:ntriples
    
    #TODO: this doesn't work (needs to be converted to statments or 
    # a way of inserting raw strings needs to be figured out.
    load_statements(n3_for(dump(var))) if parse_type==:turtle
  end

  def vars
    @R.eval("ls()").payload
  end

end
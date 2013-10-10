module PubliSci
  # handles connection and messaging to/from the triple store
  class Store
    include PubliSci::Query

    def defaults
      {
        type: :fourstore,
        url: "http://localhost:8080", #TODO port etc should eventually be extracted from URI if given
        replace: false
      }
    end

    def add(file,graph)
      if @options[:type] == :graph
        throw "please provide an RDF::Repository" unless graph.is_a? RDF::Repository
        graph.load(file)
        @store = graph
        @store
      elsif @options[:type] == :fourstore
        if @options[:replace]
          `curl -T #{file} -H 'Content-Type: application/x-turtle' #{@options[:url]}/data/http%3A%2F%2Frqtl.org%2F#{graph}`
        else
          `curl --data-urlencode data@#{file} -d 'graph=http%3A%2F%2Frqtl.org%2F#{graph}' -d 'mime-type=application/x-turtle' #{@options[:url]}/data/`
        end
      end
    end

    def add_all(dir, graph, pattern=nil)
      pattern = /.+\.ttl/ if pattern == :turtle || pattern == :ttl

      files = Dir.entries(dir) - %w(. ..)
      files = files.grep(pattern) if pattern.is_a? Regexp
      nfiles = files.size
      n = 0
      files.each{|file| puts file + " #{n+=1}/#{nfiles} files"; puts add(file,graph)}
    end

    def initialize(options={})
      @options = defaults.merge(options)
    end

    def query(string)
      # execute(string, )
      if @options[:type] == :graph
        execute(string, @store, :graph)
      elsif @options[:type] == :fourstore
        execute(string, @options[:url], :fourstore)
      end
    end

    def url
      @options[:url]
    end
  end
end

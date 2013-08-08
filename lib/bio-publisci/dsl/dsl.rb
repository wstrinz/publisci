module PubliSci
  module DSL
    attr_reader :base_url

    # Use to set base url for whole script; helps when referring to dataset
    # resources from metadata and
    def base_url=(url)
      @base_url = url
      Prov.base_url=url
    end

    def data(&block)
      inst=PubliSci::Dataset::DSL::Instance.new
      inst.instance_eval(&block)
      @_dsl_data ||= [] << inst
      inst
    end

    def metadata(&block)
      inst=PubliSci::Metadata::DSL::Instance.new
      inst.instance_eval(&block)
      @_dsl_metadata = inst
      inst
    end

    def provenance(&block)
      inst=PubliSci::Prov::DSL::Instance.new
      inst.instance_eval(&block)
      @_dsl_prov = inst
      inst
    end

    def configuration
      @_dsl_config ||= DSL::Configuration.new
    end

    def configure
      yield configuration
    end

    def settings
      configuration
    end

    def generate_n3
      out = ""
      @_dsl_data.each{|dat| out << dat.generate_n3 } if @_dsl_data
      out << @_dsl_metadata.generate_n3 if @_dsl_metadata
      out << @_dsl_prov.generate_n3 if @_dsl_prov
      out
    end

    def to_repository(turtle_string=generate_n3)
      repo = settings.repository
      case repo
      when :in_memory
        repo = RDF::Repository.new
      when :fourstore
        repo = RDF::FourStore::Repository.new('http://localhost:8080')
      end
      f=Tempfile.new(['repo','.ttl'])
      f.write(turtle_string)
      f.close
      repo.load(f.path, :format => :ttl).to_s
      f.unlink
      repo
    end
  end
end
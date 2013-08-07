module PubliSci
  module DSL
    def data

    end

    def metadata(&block)

    end

    def provenance(&block)
      puts PubliSci::Prov::DSL.module_eval(&block)
    end
  end
end
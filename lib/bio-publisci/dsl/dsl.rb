module PubliSci
  module DSL
    def data

    end

    def metadata(&block)
      inst=PubliSci::Metadata::DSL::Instance.new
      inst.instance_eval(&block)
      inst
    end

    def provenance(&block)
      inst=PubliSci::Prov::DSL::Instance.new
      inst.instance_eval(&block)
      inst
    end
  end
end
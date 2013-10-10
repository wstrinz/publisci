module PubliSci
  class Dataset
    extend PubliSci::Interactive
    extend PubliSci::Registry

    def self.configuration
      @config ||= Dataset::Configuration.new
    end

  end
end
module PubliSci
  module Vocabulary
    def vocabulary(url)
      raise "InvalidVocabulary: #{url} is not a valid URI" unless RDF::Resource(url).valid?
      RDF::Vocabulary.new(url)
    end
  end
end
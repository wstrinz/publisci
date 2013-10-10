begin
  require 'spira'
  module PubliSci
    class Metadata
      module Model
        PROV ||= RDF::Vocabulary.new(RDF::URI.new('http://www.w3.org/ns/prov#'))
        QB ||= RDF::Vocabulary.new(RDF::URI.new('http://purl.org/linked-data/cube#'))
        DCT ||= RDF::Vocabulary.new(RDF::URI.new('http://purl.org/dc/terms/'))


        class Meta < Spira::Base
          type PROV.Entity
          type QB.DataSet
          property :label, predicate: RDF::RDFS.label
          property :comment, predicate: RDF::RDFS.comment
          property :description, predicate: DCT.description
          property :creator, predicate: DCT.creator
          property :issued, predicate: DCT.issued
        end
      end
    end
  end
rescue LoadError
  # puts "spira not installed, ORM unavailable"
end
require 'rdf/4store'
begin
  require 'spira'
  module PubliSci
    module ORM
      QB ||= RDF::Vocabulary.new(RDF::URI.new('http://purl.org/linked-data/cube#'))

      class Component < Spira::Base
        type QB.ComponentSpecification
        property :dimension, predicate: QB.dimension # RDF::URI.new('http://purl.org/linked-data/cube#dimension')
        property :measure, predicate: QB.measure # RDF::URI.new('http://purl.org/linked-data/cube#measure')
      end

      class DataStructureDefinition < Spira::Base
        type QB.DataStructureDefinition
        property :label, predicate: RDFS.label
        has_many :component, predicate: QB.component
      end

      class DataSet < Spira::Base
        type QB.DataSet
        property :label, predicate: RDFS.label
        property :structure, predicate: QB.structure
      end

      class Dimension < Spira::Base
        type QB.DimensionProperty
        property :range, predicate: RDFS.range
        property :label, predicate: RDFS.label
      end

      class Measure < Spira::Base
        type QB.MeasureProperty
        property :label, predicate: RDFS.label
      end


      def load_repo(repo)
        raise "Not an RDF::Repository - #{repo}" unless repo.is_a? RDF::Repository
        Spira.repository = repo
      end

      class Observation < Spira::Base
        type QB.Observation
        property :label, predicate: RDFS.label
        property :dataset, predicate: QB.dataSet

        def load_properties
          comps = RDF::URI(RDF::URI(dataset).as(DataSet).structure).as(DataStructureDefinition).component.map{|comp| RDF::URI(comp).as(Component)}
          props = comps.map{|comp| comp.dimension ? RDF::URI(comp.dimension).as(Dimension) : RDF::URI(comp.measure).as(Measure) }
          props.each{|prop|
            ss =  strip_uri(prop.subject.to_s)

            self.class.property ss.to_sym, predicate: prop.subject
          }
        end

        def strip_uri(uri)
          uri = uri.to_s.dup
          uri[-1] = '' if uri[-1] == '>'
          uri.to_s.split('/').last.split('#').last
        end

      end

      def reload_observation
        PubliSci::ORM.send(:remove_const, "Observation")
        observation
      end

      def strip_uri(uri)
        uri = uri.to_s.dup
        uri[-1] = '' if uri[-1] == '>'
        uri.to_s.split('/').last.split('#').last
      end
    end
  end
rescue LoadError
  # puts "Skipping ORM load"
end

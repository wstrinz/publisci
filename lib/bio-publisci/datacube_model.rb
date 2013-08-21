require 'rdf/4store'

module PubliSci
  module ORM
    # class Observation < Spira::Base
    #   type RDF::URI.new('http://purl.org/linked-data/cube#Observation')
    #   property :label, predicate: RDFS.label

    # end
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
      Spira.add_repository :default, repo
    end

    # def observation
    #   unless PubliSci::ORM.const_defined?("Observation")
    #     obs = Class.new(Spira::Base) do
    #       type RDF::URI.new('http://purl.org/linked-data/cube#Observation')

    #       property :structure, predicate: QB.dataSet

    #       ((Dimension.each.to_a | Measure.each.to_a) || []).each{|component|
    #         property strip_uri(component.subject.to_s), predicate: component.subject
    #       }
    #     end
    #     PubliSci::ORM.const_set("Observation",obs)
    #   end
    #   Observation
    # end

    class Observation < Spira::Base
      type QB.Observation
      property :label, predicate: RDFS.label
      property :dataset, predicate: QB.dataSet

      def load_properties
        comps = dataset.as(DataSet).structure.as(DataStructureDefinition).component.map{|comp| comp.as(Component)}
        props = comps.map{|comp| comp.dimension ? comp.dimension.as(Dimension) : comp.measure.as(Measure) }
        props.each{|prop|
          ss =  strip_uri(prop.subject.to_s)

          self.class.property ss.to_sym, predicate: prop.subject
        }
      end

      # for testing; DRY up eventually
      def strip_uri(uri)
        uri = uri.to_s.dup
        uri[-1] = '' if uri[-1] == '>'
        uri.to_s.split('/').last.split('#').last
      end

      # def method_missing(meth, *args, &block)
      #         if meth.to_s =~ /^find_by_(.+)$/
      #           run_find_by_method($1, *args, &block)
      #         else
      #           super # You *must* call super if you don't handle the
      #                 # method, otherwise you'll mess up Ruby's method
      #                 # lookup.
      #         end
      #       end
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

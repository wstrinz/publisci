require 'rdf/4store'

begin
  require 'spira'

module PubliSci
  module Prov
    module Model
      PROV ||= RDF::Vocabulary.new(RDF::URI.new('http://www.w3.org/ns/prov#'))

      class Entity < Spira::Base
        type PROV.Entity
        property :label, predicate: RDF::RDFS.label
        property :wasGeneratedBy, predicate: PROV.wasGeneratedBy
        has_many :wasAttributedTo, predicate: PROV.wasAttributedTo
        has_many :wasDerivedFrom, predicate: PROV.wasDerivedFrom
        has_many :qualifiedAssociation, predicate: PROV.qualifiedAssociation

        def organization
          wasAttributedTo.map{|src|
            if Agent.for(src).actedOnBehalfOf
              Agent.for(Agent.for(src).actedOnBehalfOf).label
            end
          }
        end
      end

      class Agent < Spira::Base
        type PROV.Agent
        type PROV.Organization
        type PROV.SoftwareAgent
        type PROV.Person
        property :label, predicate: RDF::RDFS.label
        property :wasGeneratedBy, predicate: PROV.wasGeneratedBy
        property :foaf_name, predicate: RDF::FOAF.name
        property :foaf_given, predicate: RDF::FOAF.givenName
        property :name, predicate: PROV.actedOnBehalfOf
        property :actedOnBehalfOf, predicate: PROV.actedOnBehalfOf

        def name
          foaf_given || foaf_name
        end
      end

      class Activity < Spira::Base
        type PROV.Activity
        property :label, predicate: RDF::RDFS.label
        has_many :generated, predicate: PROV.generated
        has_many :used, predicate: PROV.used
        has_many :wasAssociatedWith, predicate: PROV.wasAssociatedWith
        has_many :qualifiedAssociation, predicate: PROV.qualifiedAssociation
      end


      class Association < Spira::Base
        type PROV.Association
        property :label, predicate: RDF::RDFS.label
        property :agent, predicate: PROV.agent
        property :hadPlan, predicate: PROV.plan
      end

      class Derivation < Spira::Base
        type PROV.Derivation
        property :label, predicate: RDF::RDFS.label
        property :agent, predicate: PROV.agent
        property :hadPlan, predicate: PROV.plan
      end

      class Plan < Spira::Base
        type PROV.Plan
        property :label, predicate: RDF::RDFS.label
        property :comment, predicate: RDF::RDFS.comment
      end
    end
  end
end
rescue LoadError
  # puts "spira not installed, ORM unavailable"
end
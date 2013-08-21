require 'rdf/4store'

# begin
  # require 'spira'

module PubliSci
  class Prov
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

        def all_types
          me = self.subject
          type_query = RDF::Query.new do
            pattern [me, RDF.type, :type]
          end

          type_query.execute(self.class.repository).map{|t| t[:type]}
        end

        def has_data?
          all_types.include?('http://purl.org/linked-data/cube#DataSet')
        end

      end

      class Agent < Spira::Base
        type PROV.Agent
        type PROV.Organization
        type PROV.SoftwareAgent
        type PROV.Person
        property :label, predicate: RDF::RDFS.label
        property :foaf_name, predicate: RDF::FOAF.name
        property :foaf_given, predicate: RDF::FOAF.givenName
        property :actedOnBehalfOf, predicate: PROV.actedOnBehalfOf


        def name
          foaf_given || foaf_name
        end

        def name=(name)
          foaf_given = name
          foaf_name = name

        end

        def activities
          #should do this in a SPARQL query instead
          Activity.enum_for.map{|act|
            subj = subject()
            act if act.wasAssociatedWith.any?{|assoc| assoc == subj}
          }.reject{|x| x==nil}
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
        property :hadPlan, predicate: PROV.hadPlan

        def activity
          Activity.each.to_a.select{|act| act.qualifiedAssociation.include? self}
        end
      end

      class Derivation < Spira::Base
        type PROV.Derivation
        property :label, predicate: RDF::RDFS.label
        property :agent, predicate: PROV.agent
        property :hadPlan, predicate: PROV.hadPlan
      end

      class Plan < Spira::Base
        type PROV.Plan
        property :label, predicate: RDF::RDFS.label
        property :comment, predicate: RDF::RDFS.comment
      end
    end
  end
end
# rescue LoadError
#   puts "spira not installed, ORM unavailable"
# end
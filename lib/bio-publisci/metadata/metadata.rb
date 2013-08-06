class String
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
  end
end

module R2RDF
  module Metadata
    include R2RDF::Parser

    def defaults
    {
      encode_nulls: false,
      base_url: "http://www.rqtl.org",
    }
    end

    def basic(fields)
      #TODO don't assume base dataset is "ns:dataset-var",
      #make it just "var", and try to make that clear to calling classes

      fields[:var] = sanitize([fields[:var]]).first

      unless fields[:creator]
        if ENV['USER']
          fields[:creator] = ENV['USER']
        elsif ENV['USERNAME']
          fields[:creator] = ENV['USERNAME']
        end
      end

      fields[:date] = Time.now.strftime("%Y-%m-%d") unless fields[:date]

      #TODO some of these should probably be resources, eg dct:creator, or put under DC namespace
      str = <<-EOF.unindent
      ns:dataset-#{fields[:var]} rdfs:label "#{fields[:title]}";
        dct:title "#{fields[:title]}";
        dct:creator "#{fields[:creator]}";
        rdfs:comment "#{fields[:description]}";
        dct:description "#{fields[:description]}";
        dct:issued "#{fields[:date]}"^^xsd:date;
      EOF

      end_str = ""

      if fields[:subject] && fields[:subject].size > 0
        str << "  dct:subject"
        fields[:subject].each{|subject|
          sub = RDF::Resource(subject)
          sub = RDF::Literal(subject) unless sub.valid?

          str << " " + sub.to_base + ",\n"
        }
        str[-2] = ";"
      end

      if fields[:publishers]
        fields[:publishers].map{|publisher|
          raise "No URI for publisher #{publisher}" unless publisher[:uri]
          raise "No label for publisher #{publisher}" unless publisher[:label]
          str << "  dct:publisher <#{publisher[:uri]}> ;\n"
          end_str << "<#{publisher[:uri]}> a org:Organization, foaf:Agent;\n  rdfs:label \"#{publisher[:label]}\" .\n\n"
        }
        str[-2] = '.'
      end

      str + "\n" + end_str
    end

    def provenance(original, triplified, chain, options={})
      #TODO: should either add a prefixes method or replace some with full URIs
      raise "MissingOriginal: must specify a provenance source" unless original && original[:resource]

      #TODO include file type etc, or create a separate method for it

      str = <<-EOF.unindent
        <#{original[:resource]}> a prov:Entity ;
          prov:wasGeneratredBy ns:activity-1 .

        ns:activity-1 a prov:Activity ;
          prov:generated <#{original[:resource]}> .

      EOF

      if original[:software]
        original_assoc_id = Time.now.nsec.to_s(32)


        str << <<-EOF.unindent
          <#{original[:software]}> a prov:Entity.

          ns:activity-1 prov:qualifiedAssociation ns:assoc-1_#{original_assoc_id} .

          ns:assoc-1_#{original_assoc_id} a prov:Assocation ;
            prov:entity <#{original[:software]}> .

        EOF

        if original[:process]
          original[:process] = IO.read(original[:process]) if File.exist? original[:process]

          steps = '"' + original[:process].split("\n").join('" "') + '"'
          str << <<-EOF.unindent
            ns:assoc-1_#{original_assoc_id} prov:hadPlan ns:plan-1.

            ns:plan-1 a prov:Plan ;
              rdfs:comment (#{steps});

          EOF
        end
      end

      if original[:author]
        str << "<#{original[:author]}> a prov:Agent, prov:Person .\n"
        str << "ns:activity-1 prov:wasAssociatedWith <#{original[:author]}> .\n"

        str << "<#{original[:author]}> foaf:givenName \"#{original[:author_name]}\" .\n" if original[:author_name]

        if original[:organization]
          str << "<#{original[:author]}> prov:actedOnBehalfOf <#{original[:organization]}> .\n\n"
          str << "<#{original[:organization]}> a prov:Agent, prov:Organization.\n"
          if original[:organization_name]
            str << "<#{original[:organization]}> foaf:name \"#{original[:organization_name]}\" .\n\n"
          else
            str << "\n"
          end
        else
          str << "\n"
        end
      end

      if triplified
        triples_assoc_id = Time.now.nsec.to_s(32)

        str << <<-EOF.unindent
          <#{triplified[:resource]}> a prov:Entity;
            prov:wasGeneratredBy ns:activity-0 .

          </ns/R2RDF> a prov:Agent, prov:SoftwareAgent ;
            rdfs:label "Semantic Publishing Toolkit" .

          ns:activity-0 a prov:Activity ;
            prov:qualifiedAssociation ns:assoc-0_#{triples_assoc_id};
            prov:generated <#{triplified[:resource]}> ;
            prov:used <#{original[:resource]}> .

          ns:assoc-0_#{triples_assoc_id} a prov:Assocation ;
            prov:entity </ns/R2RDF>;
            prov:hadPlan ns:plan-0.

          ns:plan-0 a prov:Plan ;
            rdfs:comment "generation of <#{triplified[:resource]}> by R2RDF gem" .

        EOF

        if triplified[:author]
          str << "<#{triplified[:author]}> a prov:Agent, prov:Person .\n"

          str << "<#{triplified[:author]}> foaf:givenName \"#{triplified[:author_name]}\" .\n" if triplified[:author_name]

          if triplified[:organization]
            str << "<#{triplified[:author]}> prov:actedOnBehalfOf <#{triplified[:organization]}> .\n\n"
            str << "<#{triplified[:organization]}> a prov:Agent, prov:Organization.\n"
            if triplified[:organization_name]
              str << "<#{triplified[:organization]}> foaf:name \"#{triplified[:organization_name]}\" .\n\n"
            else
              str << "\n"
            end
          else
            str << "\n"
          end
        end
      end

      if chain
        str << "ns:activity-1 prov:used <#{chain.first[:resource]}> .\n"
        str << "<#{original[:resource]}> prov:wasDerivedFrom <#{chain.first[:resource]}> .\n\n"
        chain.each_with_index{ |src,i|
          if i == chain.size-1
            str << activity(src[:resource],nil,src)
          else
            str << activity(src[:resource],chain[i+1][:resource],src)
          end
        }
      end

      str
    end

    def activity(entity, used, options={})
      assoc_id = Time.now.nsec.to_s(32)
      activity_id = Time.now.nsec.to_s(32)
      plan_id = Time.now.nsec.to_s(32)

      raise "NoEntityGiven: activity generation requires a subject entity" unless entity

      entity_str = <<-EOF.unindent
        <#{entity}> a prov:Entity ;
          prov:wasGeneratredBy ns:activity-a_#{activity_id} ;
      EOF

      activity_str = <<-EOF.unindent
        ns:activity-a_#{activity_id} a prov:Activity ;
          prov:generated <#{entity}> ;
      EOF

      if used
        entity_str << "\tprov:wasDerivedFrom <#{used}> . \n\n"
        activity_str << "\tprov:used <#{used}> . \n\n"
      else
        entity_str[-2] = ".\n"
        activity_str[-2] = ".\n"
      end

      activity_str << <<-EOF.unindent
        ns:activity-a_#{activity_id} prov:qualifiedAssociation ns:assoc-s_#{assoc_id} .

        ns:assoc-s_#{assoc_id} a prov:Assocation .

      EOF

      if options[:software]

        activity_str << <<-EOF.unindent
          <#{options[:software]}> a prov:Entity .

          ns:assoc-s_#{assoc_id} prov:agent <#{options[:software]}> .
        EOF

        if options[:process]
          options[:process] = IO.read(options[:process]) if File.exist? options[:process]

          steps = '"' + options[:process].split("\n").join('" "') + '"'
          activity_str << <<-EOF.unindent
            ns:assoc-s_#{assoc_id} prov:hadPlan ns:plan-p_#{plan_id}.

            ns:plan-p_#{plan_id} a prov:Plan ;
              rdfs:comment (#{steps});
          EOF
        end
      end

      if options[:author]
        entity_str << "<#{options[:author]}> a prov:Agent, prov:Person .\n"
        entity_str << "<#{options[:author]}> foaf:givenName \"#{options[:author_name]}\" .\n" if options[:author_name]

        activity_str << "ns:activity-a_#{activity_id} prov:wasAssociatedWith <#{options[:author]}> .\n"
        activity_str << "ns:assoc-s_#{assoc_id} prov:agent <#{options[:author]}> .\n"

        if options[:organization]
          entity_str << "<#{options[:organization]}> a prov:Agent, prov:Organization .\n"
          activity_str << "<#{options[:author]}> prov:actedOnBehalfOf <#{options[:organization]}> .\n\n"
          if options[:organization_name]
            entity_str << "<#{options[:organization]}> foaf:name \"#{options[:organization_name]}\" .\n\n"
          end
        else
          activity_str << "\n"
          # entity_str << "\n"
        end
      end

      entity_str + "\n" + activity_str
    end

    def process(id, step_string, software_resource, software_var, options={})
      #TODO a better predicate for the steplist than rdfs:comment
      # and make sure it looks good.
      steps = '"' + step_string.split("\n").join('" "') + '"'
      assoc_id = Time.now.nsec.to_s(32)
      str = <<-EOF.unindent
        ns:activity-#{id} a prov:Activity ;
          prov:qualifiedAssociation ns:assoc-#{assoc_id} ;
          prov:used </ns/dataset/#{software_var}#var>.

        ns:assoc-#{id}_#{assoc_id} a prov:Assocation ;
          prov:entity <#{software_resource}>;
          prov:hadPlan ns:plan-#{id}.

        ns:plan-#{id} a prov:Plan ;
          rdfs:comment (#{steps});

      EOF

    end

    def r2rdf_metadata
      str <<-EOF.unindent
      <#{options[:base_url]}/ns/R2RDF> a foaf:Agent;
        foaf:name "R2RDF Semantic Web Toolkit";
        org:memberOf <http://sciruby.com/>
      EOF
    end

    def org_metadata
      str <<-EOF.unindent
        <http://sciruby.com/> a org:Organization, prov:Organization;
          skos:prefLabel "SciRuby";
          rdfs:description "A Project to Build and Improve Tools for Scientific Computing in Ruby".
      EOF
    end

    def metadata_help(topic=nil)
      if topic
        puts "This should display help information for #{topic}, but there's none here yet :("
      else
        puts <<-EOF.unindent
        Available metadata fields:
        (Field)         (Ontology)                              (Description)

        publishers      dct/foaf/org        The Organization/s responsible for publishing the dataset
        subject         dct                 The subject of this dataset. Use resources when possible
        var             dct                 The name of the datset resource (used internally)
        creator         dct                 The person or process responsible for creating the dataset
        description     dct/rdfs            A descriptions of the dataset
        issued          dct                 The date of issuance for the dataset

        EOF
      end
    end
  end
end
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

    def basic(fields, options={} )
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

      options = defaults().merge(options)
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
        str << "\tdct:subject \n"
        fields[:subject].each{|subject| str << "\t\t" + subject + ",\n" }
        str[-2] = ";"
      end

      if fields[:publishers]
        fields[:publishers].map{|publisher|
          raise "No URI for publisher #{publisher}" unless publisher[:uri]
          raise "No label for publisher #{publisher}" unless publisher[:label]
          str << "\tdct:publisher <#{publisher[:uri]}> ;\n"
          end_str << "<#{publisher[:uri]}> a org:Organization, foaf:Agent;\n\trdfs:label \"#{publisher[:label]}\" .\n\n"
        }
        str[-2] = '.'
      end

      str + "\n" + end_str
    end

    def provenance(fields, options={})
      #TODO: should either add a prefixes method or replace some with full URIs
      var = sanitize([fields[:var]]).first
      creator = fields[:creator] if fields[:creator] #should be URI
      org = fields[:organization] if fields[:organization] #should be URI
      source_software = fields[:software] # software name, object type, optionally steps list for, eg, R
      str = "ns:dataset-#{var} a prov:Entity.\n"
      endstr = <<-EOF.unindent
      ns:dataset-#{var} prov:wasGeneratredBy <#{options[:base_url]}/ns/R2RDF> .
      
      <#{options[:base_url]}/ns/R2RDF> a prov:Agent.
      EOF

      if creator
        endstr << "<#{options[:base_url]}/ns/R2RDF> prov:actedOnBehalfOf <#{creator}> .\n"
        endstr << "<#{creator}> a prov:Agent, prov:Person .\n"

        if org
          endstr << "<#{creator}> prov:actedOnBehalfOf <#{org}> .\n"
          endstr << "<#{org}> a prov:Agent, prov:Organization .\n"
        end
      end

      if source_software
        source_software = [source_software] unless source_software.is_a? Array
        source_software.each_with_index.map{|soft,i|
          str << "<#{options[:base_url]}/ns/prov/software/#{soft[:name]}> a prov:Entity .\n"

          endstr << "ns:dataset-#{var} prov:wasDerivedFrom <#{options[:base_url]}/ns/dataset/#{var}#var> .\n"

          if soft[:process]
            if File.exist? soft[:process]
              soft[:process] = IO.read(soft[:process])
            end
            endstr << "<#{options[:base_url]}/ns/dataset/#{var}#var> prov:wasGeneratredBy ns:activity-#{i} .\n" 
            endstr << process(i, soft[:process],"#{options[:base_url]}/ns/prov/software/#{soft[:name]}")
          end
        }
      end
      str + "\n" + endstr
    end

    def process(id, step_string, software_resource, options={})      
      #TODO a better predicate for the steplist than rdfs:comment
      # and make sure it looks good.
      steps = '"' + step_string.split("\n").join('" "') + '"'
      str = <<-EOF.unindent
        ns:activity-#{id} a prov:Activity ;
          prov:qualifiedAssociation [
            a prov:Assocation ;
            prov:entity <#{software_resource}>;
            prov:hadPlan ns:plan-#{id}
          ].

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
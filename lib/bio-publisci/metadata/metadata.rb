class String
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
  end
end

module R2RDF
  module Metadata
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
      source_software = fields[:software] # software name, object type, optionally steps list for, eg, R

      str = "qb:dataset-#{var} a prov:Entity.\n"
      endstr = "qb:dataset-#{var} prov:wasGeneratredBy <#{options[:base_url]}/ns/R2RDF>\n" #replace once gem has an actual name
      if source_software
        source_software = [source_software] unless source_software.respond_to? :map
        source_software.map{|soft|
          str << "<#{options[:base_url]}/ns/prov/software/#{soft}> a prov:Entity .\n"

          #Note: probably should say derived from the software object, then software object from software.
          endstr << "qb:dataset-#{var} prov:wasDerivedFrom <#{options[:base_url]}/ns/prov/#{soft}> .\n"
        }
      end
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
        <http://sciruby.com/> a org:Organization;
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
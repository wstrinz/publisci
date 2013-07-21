  #monkey patch to make rdf string w/ heredocs prettier ;)  
class String
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
  end
end

module R2RDF
  module Dataset
    module DataCube
      def defaults
      {
        type: :dataframe,
        encode_nulls: false,
        base_url: "http://www.rqtl.org",
      }
      end

      def generate_resources(measures, dimensions, codes, options={})
        newm = measures.map {|m|
          if m =~ /^http:\/\//
            "<#{m}>"
          elsif m =~ /^[a-zA-z]+:[a-zA-z]+$/
            m
          else
            "prop:#{m}"
          end            
        }

        newc = []

        newd = dimensions.map{|d|
            if d =~ /^http:\/\//
              newc << "<#{d}>" if codes.include? d
              "<#{d}>"
            elsif d =~ /^[a-zA-z]+:[a-zA-z]+$/
              d
            else
              newc << "prop:#{d}" if codes.include? d
              "prop:#{d}"
            end
        }
        [newm, newd, newc]
      end

      def encode_data(codes,data,var,options={})
        new_data = {}
        data.map{|k,v|
          if codes.include? k
            new_data[k] = v.map{|val|
              if val =~ /^http:\/\//
                "<#{val}>"
              elsif val =~ /^[a-zA-z]+:[a-zA-z]+$/
                val
              else
                "<code/#{k.downcase}/#{val}>"
              end
            }
          else
            new_data[k] = v
          end
        }
        new_data
      end

      def vocabulary(vocab,options={})
        if vocab.is_a?(String) && vocab =~ /^http:\/\//
          RDF::Vocabulary.new(vocab)
        elsif RDF.const_defined? vocab.to_sym && RDF.const_get(vocab.to_sym).inspect =~ /^RDF::Vocabulary/
          RDF.const_get(vocab)
        else
          nil
        end
      end
     
      def generate(measures, dimensions, codes, data, observation_labels, var, options={})
        dimensions = sanitize(dimensions)
        codes = sanitize(codes)
        measures = sanitize(measures)
        var = sanitize([var]).first
        data = sanitize_hash(data)

        str = prefixes(var,options)
        str << data_structure_definition((measures | dimensions), var, options)
        str << dataset(var, options)
        component_specifications(measures, dimensions, var, options).map{ |c| str << c }
        dimension_properties(dimensions, codes, var, options).map{|p| str << p}
        measure_properties(measures, var, options).map{|p| str << p}
        code_lists(codes, data, var, options).map{|l| str << l}
        concept_codes(codes, data, var, options).map{|c| str << c}
        observations(measures, dimensions, codes, data, observation_labels, var, options).map{|o| str << o}
        str
      end

      def sanitize(array)
        #remove spaces and other special characters
        processed = []
        array.map{|entry|
          if entry.is_a? String
            processed << entry.gsub(/[\s\.]/,'_')
          else
            processed << entry
          end
        }
        processed
      end

      def sanitize_hash(h)
        mappings = {}
        h.keys.map{|k| 
          if(k.is_a? String)
            mappings[k] = k.gsub(' ','_')
          end
        }

        h.keys.map{|k|
          h[mappings[k]] = h.delete(k) if mappings[k]
        }

        h
      end

      def prefixes(var, options={})
        var = sanitize([var]).first
        options = defaults().merge(options)
        base = options[:base_url]
        <<-EOF.unindent
        @base <#{base}/ns/dc/> .
        @prefix ns:    <#{base}/ns/dataset/#{var}#> .
        @prefix qb:    <http://purl.org/linked-data/cube#> .
        @prefix rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
        @prefix rdfs:  <http://www.w3.org/2000/01/rdf-schema#> .
        @prefix prop:  <#{base}/dc/properties/> .
        @prefix dct:   <http://purl.org/dc/terms/> .
        @prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .
        @prefix cs:    <#{base}/dc/dataset/#{var}/cs/> .
        @prefix code:  <#{base}/dc/dataset/#{var}/code/> .
        @prefix class: <#{base}/dc/dataset/#{var}/class/> .
        @prefix owl:   <http://www.w3.org/2002/07/owl#> .
        @prefix skos:  <http://www.w3.org/2004/02/skos/core#> .
        @prefix foaf:     <http://xmlns.com/foaf/0.1/> .
        @prefix org:      <http://www.w3.org/ns/org#> .
        @prefix prov:     <http://www.w3.org/ns/prov#> .

        EOF
      end

      def data_structure_definition(components,var,options={})
        var = sanitize([var]).first
        options = defaults().merge(options)
        str = "ns:dsd-#{var} a qb:DataStructureDefinition;\n"
        str << "  qb:component\n"
        components.map{|n|
              str << "    cs:#{n} ,\n"
        }
        str[-2]='.'
        str<<"\n"
        str
      end

      def dataset(var,options={})
        var = sanitize([var]).first
        options = defaults().merge(options)
        <<-EOF.unindent    
        ns:dataset-#{var} a qb:DataSet ;
          rdfs:label "#{var}"@en ;
          qb:structure ns:dsd-#{var} .

        EOF
      end

      def component_specifications(measure_names, dimension_names, var, options={})
        options = defaults().merge(options)
        specs = []
        
          dimension_names.map{|d|
          specs << <<-EOF.unindent
            cs:#{d} a qb:ComponentSpecification ;
              rdfs:label "#{d} Component" ;
              qb:dimension prop:#{d} .

            EOF
          }

          measure_names.map{|n|
            specs << <<-EOF.unindent
              cs:#{n} a qb:ComponentSpecification ;
                rdfs:label "#{n} Component" ;
                qb:measure prop:#{n} .

              EOF
          }
        
        specs
      end

      def dimension_properties(dimensions, codes, var, options={})
        options = defaults().merge(options)
        props = []
        
          dimensions.map{|d|  
            if codes.include?(d)
              props << <<-EOF.unindent
              prop:#{d} a rdf:Property, qb:DimensionProperty ;
                rdfs:label "#{d}"@en ;
                qb:codeList code:#{d.downcase} ;
                rdfs:range code:#{d.downcase.capitalize} .

              EOF
            else
              props << <<-EOF.unindent
              prop:#{d} a rdf:Property, qb:DimensionProperty ;
                rdfs:label "#{d}"@en .

              EOF
            end
          }
        
        props
      end

      def measure_properties(measures, var, options={})
        options = defaults().merge(options)
        props = []
        
          measures.map{ |m|
              
            props <<  <<-EOF.unindent
            prop:#{m} a rdf:Property, qb:MeasureProperty ;
              rdfs:label "#{m}"@en .

            EOF
            }
        
        props
      end

      def observations(measures, dimensions, codes, data, observation_labels, var, options={})  
        var = sanitize([var]).first
        options = defaults().merge(options)
        rdf_measures, rdf_dimensions, rdf_codes  = generate_resources(measures, dimensions, codes, options)
        data = encode_data(codes, data, var, options)
        obs = []
        observation_labels.each_with_index.map{|r, i|
          contains_nulls = false
          str = <<-EOF.unindent 
          ns:obs#{r} a qb:Observation ;
            qb:dataSet ns:dataset-#{var} ;
          EOF

          str << "  rdfs:label \"#{r}\" ;\n" unless options[:no_labels]
          
          dimensions.each_with_index{|d,j|
            contains_nulls = contains_nulls | (data[d][i] == nil)
            if codes.include? d
              # str << "  #{rdf_dimensions[j]} <code/#{d.downcase}/#{data[d][i]}> ;\n"
              str << "  #{rdf_dimensions[j]} #{data[d][i]} ;\n"
            else
              str << "  #{rdf_dimensions[j]} #{to_literal(data[d][i], options)} ;\n"
            end
          }

          measures.each_with_index{|m,j|
            contains_nulls = contains_nulls | (data[m][i] == nil)
            str << "  #{rdf_measures[j]} #{to_literal(data[m][i], options)} ;\n" 
            
          }

          str << "  .\n\n"
          if contains_nulls && !options[:encode_nulls]
            if options[:whiny_nils]
              raise "missing component for observation, skipping: #{str}, "
            else
              puts "missing component for observation, skipping: #{str}, "
            end
          else
            obs << str 
          end
        }
        obs
      end

      def code_lists(codes, data, var, options={})
        options = defaults().merge(options)
        data = encode_data(codes, data, var, options)
        lists = []
        codes.map{|code|
          str = <<-EOF.unindent
            code:#{code.downcase.capitalize} a rdfs:Class, owl:Class;
              rdfs:subClassOf skos:Concept ;
              rdfs:label "Code list for #{code} - codelist class"@en;
              rdfs:comment "Specifies the #{code} for each observation";
              rdfs:seeAlso code:#{code.downcase} .

            code:#{code.downcase} a skos:ConceptScheme;
              skos:prefLabel "Code list for #{code} - codelist scheme"@en;
              rdfs:label "Code list for #{code} - codelist scheme"@en;
              skos:notation "CL_#{code.upcase}";
              skos:note "Specifies the #{code} for each observation";
          EOF
          data[code].uniq.map{|value|
            unless value == nil && !options[:encode_nulls]
              str << "  skos:hasTopConcept #{to_resource(value,options)} ;\n"
            end
          }
          
          str << "  .\n\n"
          lists << str
        }
        

        lists
      end

      def concept_codes(codes, data, var, options={})
        options = defaults().merge(options)
        concepts = []
        new_data = encode_data(codes, data, var, options)
        codes.map{|code|
          new_data[code].uniq.each_with_index{|value,i|
            unless value == nil && !options[:encode_nulls]
            concepts << <<-EOF.unindent
              #{to_resource(value,options)} a skos:Concept, code:#{code.downcase.capitalize};
                skos:topConceptOf code:#{code.downcase} ;
                skos:prefLabel "#{data[code][i]}" ;
                skos:inScheme code:#{code.downcase} .

            EOF
            end
          }
        }

        concepts
      end


      def to_resource(obj, options)
        if obj.is_a? String
          #TODO decide the right way to handle missing values, since RDF has no null
          #probably throw an error here since a missing resource is a bigger problem
          obj = "NA" if obj.empty?
          
          #TODO  remove special characters (faster) as well (eg '?')
          obj.gsub(' ','_').gsub('?','')
        elsif obj == nil && options[:encode_nulls]
          '"NA"'
        elsif obj.is_a? Numeric
          #resources cannot be referred to purely by integer (?)
          "n"+obj.to_s
        else
          obj
        end
      end

      def to_literal(obj, options)
        if obj.is_a? String
          # Depressing that there's no more elegant way to check if a string is 
          # a number...
          if val = Integer(obj) rescue nil
            val
          elsif val = Float(obj) rescue nil
            val
          else
            '"'+obj+'"'
          end
        elsif obj == nil && options[:encode_nulls]
          #TODO decide the right way to handle missing values, since RDF has no null
          '"NA"'
        else
          obj
        end
      end
    end
  end
end

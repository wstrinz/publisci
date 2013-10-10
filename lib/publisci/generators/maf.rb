module PubliSci
  module Generators
    class MAF
      extend Base

      COLUMN_NAMES = %w{ Hugo_Symbol Entrez_Gene_Id Center NCBI_Build Chromosome Start_Position End_Position Strand Variant_Classification Variant_Type Reference_Allele Tumor_Seq_Allele1 Tumor_Seq_Allele2 dbSNP_RS  dbSNP_Val_Status Tumor_Sample_Barcode Matched_Norm_Sample_Barcode Match_Norm_Seq_Allele1  Match_Norm_Seq_Allele2  Tumor_Validation_Allele1  Tumor_Validation_Allele2  Match_Norm_Validation_Allele1 Match_Norm_Validation_Allele2 Verification_Status Validation_Status Mutation_Status Sequencing_Phase  Sequence_Source Validation_Method Score BAM_File  Sequencer Tumor_Sample_UUID Matched_Norm_Sample_UUID patient_id sample_id}

      COMPONENT_RANGES = { "Tumor_Sample_Barcode" => "xsd:string", "Start_position" => "xsd:int", "Center" => "xsd:string", "NCBI_Build" => "xsd:int", "Chromosome" => "xsd:int" }

      TCGA_CODES =
        {
          "Variant_Classification" => %w{Frame_Shift_Del Frame_Shift_Ins In_Frame_Del In_Frame_Ins Missense_Mutation Nonsense_Mutation Silent Splice_Site Translation_Start_Site Nonstop_Mutation 3'UTR 3'Flank 5'UTR 5'Flank IGR1  Intron RNA Targeted_Region},
          "Variant_Type" => %w{SNP DNP TNP ONP INS DEL Consolidated},
          "dbSNP_Val_Status" => %w{by1000genomes by2Hit2Allele byCluster byFrequency byHapMap byOtherPop bySubmitter alternate_allele},
          "Verification_Status" => %w{Verified, Unknown},
          "Validation_Status" => %w{Untested Inconclusive Valid Invalid},
          "Mutation_Status" => %w{None Germline Somatic LOH Post-transcriptional modification Unknown},
          "Sequence_Source" => %w{WGS WGA WXS RNA-Seq miRNA-Seq Bisulfite-Seq VALIDATION Other ncRNA-Seq WCS CLONE POOLCLONE AMPLICON CLONEEND FINISHING ChIP-Seq MNase-Seq DNase-Hypersensitivity EST FL-cDNA CTS MRE-Seq MeDIP-Seq MBD-Seq Tn-Seq FAIRE-seq SELEX RIP-Seq ChIA-PET},
          "Sequencer" => ["Illumina GAIIx", "Illumina HiSeq", "SOLID", "454", "ABI 3730xl", "Ion Torrent PGM", "Ion Torrent Proton", "PacBio RS", "Illumina MiSeq", "Illumina HiSeq 2500", "454 GS FLX Titanium", "AB SOLiD 4 System" ]
        }

      BARCODE_INDEX = COLUMN_NAMES.index('Tumor_Sample_Barcode')

      class << self
        def write(record, out, label, options={})

            options = process_options(options)

            options[:no_labels] ||= true
            options[:lookup_hugo] ||= false
            options[:complex_objects] ||= false
            options[:ranges] ||= COMPONENT_RANGES

            write_to(out, process_line(record, label, options))
        end

        def write_structure(input, output, options)
          write_to(output, structure(options))
        end

        def process_options(options)
          options[:dimensions] = dimensions = %w{Variant_Classification Variant_Type dbSNP_Val_Status Verification_Status Validation_Status Mutation_Status Sequence_Source Sequencer}
          options[:codes] = codes = dimensions
          options[:measures] = (COLUMN_NAMES - dimensions - codes)
          options[:dataset_name] ||= "MAF_#{Time.now.nsec.to_s(32)}"

          options
        end

        def process_line(entry,label,options)
            entry = (entry.fill(nil,entry.length...COLUMN_NAMES.length-2) + parse_barcode(entry[BARCODE_INDEX])).flatten

            entry[0] = "http://identifiers.org/hgnc.symbol/#{entry[0]}" if entry[0]

            # A 0 in the entrez-id column appears to mean null
            col=1
            entry[col] = nil if entry[col] == '0'
            entry[col] = "http://identifiers.org/ncbigene/#{entry[col]}" if entry[col]

            # Only link non-novel dbSNP entries
            col = COLUMN_NAMES.index('dbSNP_RS')
            if entry[col] && entry[col][0..1] == "rs"
              entry[col] = "http://identifiers.org/dbsnp/#{entry[col].gsub('rs','')}"
            end

            # optionally create typed objects using sio nodes
            if options[:complex_objects]
              entry = sio_values(entry)
            end

            data = {}
            COLUMN_NAMES.each_with_index{|col,i|
              data[col] = [entry[i]]
            }

            observations(options[:measures],options[:dimensions],options[:codes],data,[label],options[:dataset_name],options).first
        end

        def sio_values(entry)
          entry[0] = sio_value('http://edamontology.org/data_1791',entry[0]) if entry[0]

          # Link entrez genes
          col=1
          entry[col] = sio_value("http://identifiers.org/ncbigene",entry[col]) if entry[col]

          col = COLUMN_NAMES.index('dbSNP_RS')
          entry[col] = sio_value("http://identifiers.org/dbsnp", entry[col])

          # test SIO attributes for chromosome
          col = COLUMN_NAMES.index('Chromosome')
          entry[col] = sio_value("http://purl.org/obo/owl/SO#SO_0000340",entry[col])

          # More SIO attrtibutes for alleles
          %w{Reference_Allele Tumor_Seq_Allele1 Tumor_Seq_Allele2 Match_Norm_Seq_Allele1 Match_Norm_Seq_Allele2}.each{|name|
            col = COLUMN_NAMES.index(name)
            entry[col] = sio_value("http://purl.org/obo/owl/SO#SO_0001023",entry[col])
          }

          col = COLUMN_NAMES.index("Strand")
          entry[col] = sio_attribute("http://edamontology.org/data_0853",entry[col])

          col = COLUMN_NAMES.index("Center")
          entry[col] = sio_attribute("foaf:homepage",entry[col])

          # Use faldo for locations End_Position
          col = COLUMN_NAMES.index("Start_Position")
          entry[col] = sio_attribute("http://biohackathon.org/resource/faldo#begin", entry[col],"http://biohackathon.org/resource/faldo#Position")

          col = COLUMN_NAMES.index("End_Position")
          entry[col] = sio_attribute("http://biohackathon.org/resource/faldo#end", entry[col],"http://biohackathon.org/resource/faldo#Position")

          entry
        end

        def structure(options={})

          options = process_options(options)

          str = prefixes(options[:dataset_name],options)
          str << data_structure_definition(options[:measures],options[:dimensions],options[:codes],options[:dataset_name],options)
          str << dataset(options[:dataset_name],options)
          component_specifications(options[:measures], options[:dimensions], options[:codes], options[:dataset_name], options).map{ |c| str << c }
          measure_properties(options[:measures],options[:dataset_name],options).map{|m| str << m}
          dimension_properties(options[:dimensions],options[:codes], options[:dataset_name],options).map{|d| str << d}
          code_lists(options[:codes],TCGA_CODES,options[:dataset_name],options).map{|c| str << c}
          concept_codes(options[:codes],TCGA_CODES,options[:dataset_name],options).map{|c| str << c}

          str
        end

        def post_process(file)
          reg = %r{http://identifiers.org/hgnc.symbol/(\w+)}
          hugo_cache ||= {}
          PubliSci::PostProcessor.process(file,file,reg){|g|
            hugo_cache[g] ||= official_symbol(g)
           'http://identifiers.org/hgnc.symbol/' + cache[g]
         }
        end

        def column_replace(entry,column,prefix,value=nil)
          if value
            entry[COLUMN_NAMES.index(column)] = prefix + value
          else
            entry[COLUMN_NAMES.index(column)] += prefix
          end
        end

        def official_symbol(hugo_symbol)
          qry = <<-EOF

          SELECT distinct ?official where {
           {?hgnc <http://bio2rdf.org/hgnc_vocabulary:approved_symbol> "#{hugo_symbol}"}
           UNION
           {?hgnc <http://bio2rdf.org/hgnc_vocabulary:synonym> "#{hugo_symbol}"}

           ?hgnc <http://bio2rdf.org/hgnc_vocabulary:approved_symbol> ?official
          }

          EOF

          sparql = SPARQL::Client.new("http://cu.hgnc.bio2rdf.org/sparql")
          sparql.query(qry).map(&:official).first.to_s
        end

        def parse_barcode(code)
          #TCGA-E9-A22B-01A-11D-A159-09
          [code[5..11], code[13..-1]]
        end
      end
    end
  end
end
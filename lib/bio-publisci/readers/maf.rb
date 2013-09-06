module PubliSci
  module Readers
    class MAF < Base
    COLUMN_NAMES = %w{ http://identifiers.org/hgnc.symbol/ Entrez_Gene_Id Center NCBI_Build Chromosome Start_Position End_Position Strand Variant_Classification Variant_Type Reference_Allele Tumor_Seq_Allele1 Tumor_Seq_Allele2 dbSNP_RS  dbSNP_Val_Status Tumor_Sample_Barcode Matched_Norm_Sample_Barcode Match_Norm_Seq_Allele1  Match_Norm_Seq_Allele2  Tumor_Validation_Allele1  Tumor_Validation_Allele2  Match_Norm_Validation_Allele1 Match_Norm_Validation_Allele2 Verification_Status Validation_Status Mutation_Status Sequencing_Phase  Sequence_Source Validation_Method Score BAM_File  Sequencer Tumor_Sample_UUID Matched_Norm_Sample_UUID patient_id sample_id}

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

      def generate_n3(input_file, options={})

        dataset_name = options[:dataset_name] || nil
        output = options[:output] || :file
        output_base = options[:output_base] || nil

        @dimensions = %w{Variant_Classification Variant_Type dbSNP_Val_Status Verification_Status Validation_Status Mutation_Status Sequence_Source Sequencer} 
        # @codes = %w{Variant_Classification Variant_Type}
        @codes = @dimensions
        @measures = (COLUMN_NAMES - @dimensions - @codes)
        @dataset_name ||= File.basename(input_file,'.*')
        @barcode_index = COLUMN_NAMES.index('Tumor_Sample_Barcode')

        options[:no_labels] ||= true
        options[:lookup_hugo] ||= false
        options[:ranges] ||= COMPONENT_RANGES


        if output == :print
          str = structure(options)
          f = open(input_file)
          n = 0
          f.each_line{|line|
            processed = process_line(line,n.to_s,options)
            str << processed.first if processed
            n +=1
          }
          str
        else
          # TODO - allow multi file / separate structure output for very large datasets
          # open("#{file_base}_structure.ttl",'w'){|f| f.write structure(options)}
          file_base = output_base || @dataset_name

          out = open("#{file_base}.ttl",'w')
          out.write(structure(options))
          f = open(input_file)
          n = 0
          f.each_line{|line|
            processed = process_line(line,n.to_s,options)
            out.write(processed.first) if processed
            n += 1
          }
          out
        end
      end

      def process_line(line,label,options)
        unless line[0] == "#" || line[0..3] == "Hugo"
          entry = ::CSV.parse(line, {col_sep: "\t"}).flatten

          entry = (entry.fill(nil,entry.length...COLUMN_NAMES.length-2) + parse_barcode(entry[@barcode_index])).flatten

          if options[:lookup_hugo]
            entry[0] = "http://identifiers.org/hgnc.symbol/#{official_symbol(entry[0])}" if entry[0]
          else
            entry[0] = "http://identifiers.org/hgnc.symbol/#{entry[0]}" if entry[0]
          end

          # A 0 in the entrez-id column appears to mean null
          col=1
          entry[col] = nil if entry[col] == '0'

          # Link entrez genes
          entry[col] = sio_value("http://identifiers.org/ncbigene",entry[col]) if entry[col]

          # Link known SNPs
          col = COLUMN_NAMES.index('dbSNP_RS')
          if entry[col][0..1] == "rs"
            entry[col] = "http://identifiers.org/dbsnp/#{entry[col].gsub('rs','')}"
          end

          # test SIO attributes for chromosome
          col = COLUMN_NAMES.index('Chromosome')
          entry[col] = sio_attribute("http://purl.org/obo/owl/SO#SO_0000340",entry[col])

          # More SIO attrtibutes for alleles
          col = COLUMN_NAMES.index('Reference_Allele')
          entry[col] = sio_attribute("http://purl.org/obo/owl/SO#SO_0001023",entry[col])

          col = COLUMN_NAMES.index('Tumor_Seq_Allele1')
          entry[col] = sio_attribute("http://purl.org/obo/owl/SO#SO_0001023",entry[col])

          col = COLUMN_NAMES.index('Tumor_Seq_Allele2')
          entry[col] = sio_attribute("http://purl.org/obo/owl/SO#SO_0001023",entry[col])

          data = {}
          COLUMN_NAMES.each_with_index{|col,i|
            data[col] = [entry[i]]
          }

          # data = Hash[*COLUMN_NAMES.zip(entry).flatten]

          observations(@measures,@dimensions,@codes,data,[label],@dataset_name,options)
        end
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

      def structure(options={})

        str = prefixes(@dataset_name,options)
        str << data_structure_definition(@measures,@dimensions,@codes,@dataset_name,options)
        str << dataset(@dataset_name,options)
        component_specifications(@measures, @dimensions, @codes, @dataset_name, options).map{ |c| str << c }
        measure_properties(@measures,@dataset_name,options).map{|m| str << m}
        dimension_properties(@dimensions,@codes, @dataset_name,options).map{|d| str << d}
        code_lists(@codes,TCGA_CODES,@dataset_name,options).map{|c| str << c}
        concept_codes(@codes,TCGA_CODES,@dataset_name,options).map{|c| str << c}
        str
      end
    end
  end
end
module PubliSci
  module Readers
    class MAF < Base
    COLUMN_NAMES = %w{ http://identifiers.org/hgnc.symbol/ Entrez_Gene_Id  Center  NCBI_Build  Chromosome  Start_position  End_position  Strand  Variant_Classification  Variant_Type  Reference_Allele  Tumor_Seq_Allele1 Tumor_Seq_Allele2 dbSNP_RS  dbSNP_Val_Status  Tumor_Sample_Barcode  Matched_Norm_Sample_Barcode Match_Norm_Seq_Allele1  Match_Norm_Seq_Allele2  Tumor_Validation_Allele1  Tumor_Validation_Allele2  Match_Norm_Validation_Allele1 Match_Norm_Validation_Allele2 Verification_Status Validation_Status Mutation_Status Sequencing_Phase  Sequence_Source Validation_Method Score BAM_file  Sequencer Tumor_Sample_UUID Matched_Norm_Sample_UUID  Genome_Change Annotation_Transcript Transcript_Strand Transcript_Exon Transcript_Position cDNA_Change Codon_Change  Protein_Change  Other_Transcripts Refseq_mRNA_Id  Refseq_prot_Id  SwissProt_acc_Id  SwissProt_entry_Id  Description UniProt_AApos UniProt_Region  UniProt_Site  UniProt_Natural_Variations  UniProt_Experimental_Info GO_Biological_Process GO_Cellular_Component GO_Molecular_Function COSMIC_overlapping_mutations  COSMIC_fusion_genes COSMIC_tissue_types_affected  COSMIC_total_alterations_in_gene  Tumorscape_Amplification_Peaks  Tumorscape_Deletion_Peaks TCGAscape_Amplification_Peaks TCGAscape_Deletion_Peaks  DrugBank  ref_context gc_content  CCLE_ONCOMAP_overlapping_mutations  CCLE_ONCOMAP_total_mutations_in_gene  CGC_Mutation_Type CGC_Translocation_Partner CGC_Tumor_Types_Somatic CGC_Tumor_Types_Germline  CGC_Other_Diseases  DNARepairGenes_Role FamilialCancerDatabase_Syndromes  MUTSIG_Published_Results  OREGANNO_ID OREGANNO_Values t_alt_count t_ref_count validation_status validation_method validation_tumor_sample validation_alt_allele filter patient_id sample_id}

      def generate_n3(input_file, dataset_name=nil, output=:file, output_base=nil, options={})
        # TODO - coded property info not yet generated

        @dimensions = %w{Variant_Classification Variant_Type Mutation_Status Sequencing_Phase Sequence_Source filter}
        # @codes = @dimensions
        @codes = []
        @measures = (COLUMN_NAMES - @dimensions)
        @dataset_name ||= File.basename(input_file,'.*')
        @barcode_index = COLUMN_NAMES.index('Tumor_Sample_Barcode')

        # options[:encode_nulls] ||= true
        options[:no_labels] ||= true
        options[:lookup_hugo] ||= true

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
          col = COLUMN_NAMES.index('Entrez_Gene_Id')
          entry[col] = nil if entry[col] == '0'

          # Link entrez genes
          col = COLUMN_NAMES.index('Entrez_Gene_Id')
          entry[col] = "http://identifiers.org/ncbigene/#{entry[col]}" if entry[col]
          
          # Link known SNPs
          col = COLUMN_NAMES.index('dbSNP_RS')
          if entry[col][0..1] == "rs"
            entry[col] = "http://identifiers.org/dbsnp/#{entry[col].gsub('rs','')}"
          end


          data = Hash[*COLUMN_NAMES.zip(entry).flatten]

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

        str
      end
    end
  end
end
module PubliSci
  module Readers
    class MAF < Base
    COLUMN_NAMES = %w{ Hugo_Symbol Entrez_Gene_Id  Center  NCBI_Build  Chromosome  Start_position  End_position  Strand  Variant_Classification  Variant_Type  Reference_Allele  Tumor_Seq_Allele1 Tumor_Seq_Allele2 dbSNP_RS  dbSNP_Val_Status  Tumor_Sample_Barcode  Matched_Norm_Sample_Barcode Match_Norm_Seq_Allele1  Match_Norm_Seq_Allele2  Tumor_Validation_Allele1  Tumor_Validation_Allele2  Match_Norm_Validation_Allele1 Match_Norm_Validation_Allele2 Verification_Status Validation_Status Mutation_Status Sequencing_Phase  Sequence_Source Validation_Method Score BAM_file  Sequencer Tumor_Sample_UUID Matched_Norm_Sample_UUID  Genome_Change Annotation_Transcript Transcript_Strand Transcript_Exon Transcript_Position cDNA_Change Codon_Change  Protein_Change  Other_Transcripts Refseq_mRNA_Id  Refseq_prot_Id  SwissProt_acc_Id  SwissProt_entry_Id  Description UniProt_AApos UniProt_Region  UniProt_Site  UniProt_Natural_Variations  UniProt_Experimental_Info GO_Biological_Process GO_Cellular_Component GO_Molecular_Function COSMIC_overlapping_mutations  COSMIC_fusion_genes COSMIC_tissue_types_affected  COSMIC_total_alterations_in_gene  Tumorscape_Amplification_Peaks  Tumorscape_Deletion_Peaks TCGAscape_Amplification_Peaks TCGAscape_Deletion_Peaks  DrugBank  ref_context gc_content  CCLE_ONCOMAP_overlapping_mutations  CCLE_ONCOMAP_total_mutations_in_gene  CGC_Mutation_Type CGC_Translocation_Partner CGC_Tumor_Types_Somatic CGC_Tumor_Types_Germline  CGC_Other_Diseases  DNARepairGenes_Role FamilialCancerDatabase_Syndromes  MUTSIG_Published_Results  OREGANNO_ID OREGANNO_Values t_alt_count t_ref_count validation_status validation_method validation_tumor_sample validation_alt_allele filter}

      def generate_n3(input_file, dataset_name=nil, output=:file, output_base=nil, options={})
        # TODO - coded property info not yet generated
        @dimensions = %w{Variant_Classification Variant_Type Mutation_Status Sequencing_Phase Sequence_Source filter} #etc
        @codes = @dimensions
        @measures = COLUMN_NAMES - @dimensions
        @dataset_name ||= File.basename(input_file,'.*')
        options[:encode_nulls] = true

        if output == :print
          str = structure(options)
          f = open(input_file)
          f.each_line{|line|
            processed = process_line(line,options)
            str << processed.first if processed
          }
          str
        else
          file_base = output_base || @dataset_name
          open("#{file_base}_structure.ttl",'w'){|f| f.write structure(@dataset_name,options)}

          # file can be processed line by line, so no need to in-memory everything for large files
          # TODO - allow multi file output for very large datasets
          out = open("#{file_base}.ttl",'w')
          f = open(input_file)
          f.each_line{|line|
            processed = process_line(line,options)
            out.write(processed.first) if processed
          }
        end
      end

      def process_line(line,options)
        unless line[0] == "#" || line[0..3] == "Hugo"
          entry = ::CSV.parse(line, {col_sep: "\t"}).flatten
          data = Hash[*COLUMN_NAMES.zip(entry).flatten]
          data.each{|k,v| data[k]=Array(v)}

          observations(@measures,@dimensions,@codes,data,[entry[0]],@dataset_name,options)
        end
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
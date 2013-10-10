module PubliSci
  module Parsers
    class MAF
      extend Base
      COLUMN_NAMES = %w{ Hugo_Symbol Entrez_Gene_Id Center NCBI_Build Chromosome Start_Position End_Position Strand Variant_Classification Variant_Type Reference_Allele Tumor_Seq_Allele1 Tumor_Seq_Allele2 dbSNP_RS  dbSNP_Val_Status Tumor_Sample_Barcode Matched_Norm_Sample_Barcode Match_Norm_Seq_Allele1  Match_Norm_Seq_Allele2  Tumor_Validation_Allele1  Tumor_Validation_Allele2  Match_Norm_Validation_Allele1 Match_Norm_Validation_Allele2 Verification_Status Validation_Status Mutation_Status Sequencing_Phase  Sequence_Source Validation_Method Score BAM_File  Sequencer Tumor_Sample_UUID Matched_Norm_Sample_UUID patient_id sample_id}

      def self.valid?(line)
        not (line[0] == "#" || line[0..3] == "Hugo")
      end

      def enum_method
        :each_line
      end

      def self.process_record(rec)
        ::CSV.parse(rec, {col_sep: "\t"}).flatten[0..(COLUMN_NAMES.length-3)]
      end
    end
  end
end
module PubliSci
  module Readers
    class MAF < Base
      def generate_n3(input_file, options={})
        input_file = open(input_file,'r')

        out_base = options[:output_base] || File.basename(input_file,'.*')

        if options[:output] == :print
          output = StringIO.new("")
        else
          output = open "#{out_base}.ttl",'w'
        end

        # each_record should pass index as second arg
        indx = 0

        PubliSci::Generators::MAF.write_structure(input_file, output, options)

        PubliSci::Parsers::MAF.each_record(input_file) do |rec|
          PubliSci::Generators::MAF.write(rec, output, indx, options)
          indx += 1
        end

        output.close

        if options[:output] == :print
          output.string
        else
          output.path
        end
      end
    end
  end
end
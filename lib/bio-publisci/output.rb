module R2RDF
  module Reader
    module Output
      def output(string, options={},append=false)
        options[:type] = [:string] unless options[:type]
        base = options[:file_base]
        name = options[:file_name]
        types = Array(options[:type])

        if types.include? :print
          puts string
        end

        if types.include? :file
          raise "no file specified output" unless name

          method = append ? 'a' : 'w'
          open("#{base}#{name}", method) { |f| f.write str }
        end

        if types.include? :string
          string
        end
      end
    end
  end
end
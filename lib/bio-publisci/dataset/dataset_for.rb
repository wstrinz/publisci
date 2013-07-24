module R2RDF
  module Dataset
    class Dataset
      def self.for(object, options={}, ask_on_ambiguous=true)
        if object.is_a? String
          if File.exist? object
            if File.extname(object).size > 0
              extension = File.extname
            elsif File.basename(object)[0] == '.' && File.basename(object).count('.') == 1
              extension = File.basename(object)
            else
              raise "Can't load file #{object}; type inference not yet implemented"
            end

            case extension
            when ".RData"
              r_object(object, options, ask_on_ambiguous)
            end
          else
            raise "Unknown String type of data"
          end 
        else
          raise "not recognize Ruby objects yet (#{object})"
        end
      end

      def self.r_object(object, options={}, ask_on_ambiguous=true)
        if object.is_a? String
          con = Rserve::Connection.new
          vars = con.eval("load('#{File.absolute_path object}')")
          if vars.to_ruby.size > 1 && ask_on_ambiguous
            puts "Which variable? #{vars.to_ruby}"
            var = vars.to_ruby[gets.to_i]
          else
            var = vars.to_ruby[0]
          end

          r_classes = con.eval("class(#{var})").to_ruby

          if r_classes.include? "data.frame"
            df = R2RDF::Reader::Dataframe.new
            unless options[:dimensions] || !ask_on_ambiguous
              dims = con.eval("names(#{var})").to_ruby
              puts "Which dimensions? #{dims}"
              selection = gets.chomp
              if selection.size > 0
                options[:dimensions] = selection.split(',').map(&:to_i).map{|i| dims[i]}
              end
            end
            unless options[:measures] || !ask_on_ambiguous
              meas = con.eval("names(#{var})").to_ruby
              puts "Which measures? #{meas} "
              selection = gets.chomp
              if selection.size > 0
                options[:measures] = selection.split(',').map(&:to_i).map{|i| meas[i]}
              end
            end
            
            df.generate_n3(con.eval(var),var,options)
          
          elsif r_classes.include? "cross"
            bc = R2RDF::Reader::BigCross.new

            unless options[:measures] || !ask_on_ambiguous
              pheno_names = con.eval("names(#{var}$pheno)").to_ruby
              puts "Which phenotype traits? #{pheno_names}"
              selection = gets.chomp
              if selection.size > 0
                options[:measures] = selection.split(',').map(&:to_i).map{|i| pheno_names[i]}
              end
            end

            base = var
            if ask_on_ambiguous
              puts "Output file base?"
              base = gets.chomp
              base = var unless base.size > 0
            end

            bc.generate_n3(con, var, base, options)

          elsif r_classes.include? "matrix"
            mat = R2RDF::Reader::RMatrix.new

            unless options[:measures] || !ask_on_ambiguous  
              puts "Row label"
              rows = gets.chomp
              rows = "row" unless rows.size > 0

              puts "Column label"
              cols = gets.chomp
              cols = "column" unless cols.size > 0

              puts "Entry label"
              vals = gets.chomp
              vals = "value" unless vals.size > 0

              options[:measures] = [cols,rows,vals]
            end
            
            base = var
            if ask_on_ambiguous
              puts "Output file base?"
              base = gets.chomp
              base = var unless base.size > 0
            end

            mat.generate_n3(con, var, base, options)
          else
            raise "no R2RDF::Reader found for #{r_classes}"
          end

        elsif object.is_a? Rserve::REXP
          raise "support for Rserve objects coming shortly"
        else
          raise "#{object} is not an R object"
        end
      end
    end
  end 
end
module PubliSci
  module Reader
    class RCross
      include PubliSci::Dataset::DataCube
      include PubliSci::Reader::Output

      def generate_n3(client, var, outfile_base, options={})
        meas = measures(client,var,options)
        dim = dimensions(client,var,options)
        codes = codes(client,var,options)

        #write structure
        open(outfile_base+'_structure.ttl','w'){|f| f.write structure(client,var,options)}

        n_individuals = client.eval("length(#{var}$pheno[[1]])").payload.first
        chromosome_list = (1..19).to_a.map(&:to_s) + ["X"]
        chromosome_list.map{|chrom|
          open(outfile_base+"_#{chrom}.ttl",'w'){|f| f.write prefixes(var,options)}
          entries_per_individual = client.eval("length(#{var}$geno$'#{chrom}'$map)").to_ruby

          #get genotype data (currently only for chromosome 1)
          geno_chr = client.eval("#{var}$geno$'#{chrom}'")

          #get number of markers per individual

          #write observations
          n_individuals.times{|indi|
            obs_data = observation_data(client,var,chrom.to_s,indi,geno_chr,entries_per_individual,options)
            labels = labels_for(obs_data,chrom.to_s,indi)
            open(outfile_base+"_#{chrom}.ttl",'a'){|f| observations(meas,dim,codes,obs_data,labels,var,options).map{|obs| f.write obs}}
            puts "(#{chrom}) #{indi}/#{n_individuals}" unless options[:quiet]
          }
        }

      end

      def structure(client,var,options={})
        meas = measures(client,var,options)
        dim = dimensions(client,var,options)
        codes = codes(client,var,options)

        str = prefixes(var,options)
        str << data_structure_definition(meas,dim,codes,var,options)
        str << dataset(var,options)
        component_specifications(meas, dim, codes, var, options).map{ |c| str << c }
        measure_properties(meas,var,options).map{|m| str << m}

        str
      end

      def measures(client, var, options={})
        pheno_names = client.eval("names(#{var}$pheno)").to_ruby
        if options[:measures]
          (pheno_names & options[:measures]) | ["genotype","markerpos","marker"]
        else
          pheno_names | ["genotype","markerpos","marker"]
        end
        # measure_properties(measures,var,options)
      end

      def dimensions(client, var, options={})
        # dimension_properties([""],var)
        []
      end

      def codes(client, var, options={})
        []
      end

      def labels_for(data,chr,individual,options={})
        labels=(((data.first.last.size*individual)+1)..(data.first.last.size*(individual+1))).to_a.map(&:to_s)
        labels.map{|l| l.insert(0,"#{chr}_")}
        labels
      end

      def observation_data(client, var, chr, row_individ, geno_chr, entries_per_individual, options={})
        data = {}
        # geno_chr = client.eval("#{var}$geno$'#{chr}'")
        # n_individuals = client.eval("#{var}$pheno[[1]]").to_ruby.size
        # entries_per_individual = @rexp.payload["geno"].payload[row_individ].payload["map"].payload.size * @rexp.payload["geno"].payload.names.size
        data["chr"] = []
        data["genotype"] = []
        data["individual"] = []
        data["marker"] = []
        data["markerpos"] = []
        pheno_names = client.eval("names(#{var}$pheno)").to_ruby
        pheno_names.map{|name|
          data[name] = []
        }
        # n_individuals.times{|row_individ|
          # puts "#{row_individ}/#{n_individuals}"
        data["individual"] << (1..entries_per_individual).to_a.fill(row_individ)

        pheno_names.map{|name|
          data[name] << (1..entries_per_individual).to_a.fill(client.eval("#{var}$pheno$#{name}").to_ruby[row_individ])
        }
        # @rexp.payload["geno"].payload.names.map { |chr|
        num_markers = geno_chr.payload.first.to_ruby.column_size
        data["chr"] << (1..num_markers).to_a.fill(chr)
        data["genotype"] << geno_chr.payload["data"].to_ruby.row(row_individ).to_a
        data["marker"] << client.eval("names(#{var}$geno$'#{chr}'$map)").payload
        data["markerpos"] << geno_chr.payload["map"].to_a
          # }
        # }
        data.map{|k,v| v.flatten!}
        data
      end

      def num_individuals(client, var, options={})
        client.eval("#{var}$pheno").payload.first.to_ruby.size
      end


    end
  end
end
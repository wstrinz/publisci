module R2RDF
	module Reader
		class Cross
			include R2RDF::Dataset::DataCube

			def generate_n3(rexp, var, options={})
				@rexp = rexp
				@options = options
				generate(measures, dimensions, codes, observation_data, observation_labels, var, options)
			end

			def dimensions
				["individual","chr","sex","marker"]
			end

			def codes
				["individual","chr","sex","marker"]
			end

			def measures
				((@rexp.payload["pheno"].payload.names - ["sex"]) | ["genotype","markerpos"]) 
			end

			def observation_labels
				# row_names = @rexp.attr.payload["row.names"].to_ruby
				# entries_per_individual = @rexp.payload["geno"].payload[0].payload["map"].payload.size * @rexp.payload["geno"].payload.names.size
				entries_per_individual = 0
				@rexp.payload["geno"].payload.to_ruby.map{|v| entries_per_individual += (v["map"].size)}
				individuals = @rexp.payload["pheno"].payload.first.to_ruby.size
	      (1..(entries_per_individual * individuals)).to_a
			end

			def observation_data

				data = {}
				n_individuals = @rexp.payload["pheno"].payload.first.to_ruby.size
				entries_per_individual = 0
				@rexp.payload["geno"].payload.to_ruby.map{|v| entries_per_individual += (v["map"].size)}
				# entries_per_individual = @rexp.payload["geno"].payload[row_individ].payload["map"].payload.size * @rexp.payload["geno"].payload.names.size
				data["chr"] = []
				data["genotype"] = []
				data["individual"] = []
				data["marker"] = []
				data["markerpos"] = []
				@rexp.payload["pheno"].payload.names.map{|name|
					data[name] = []
				}
				n_individuals.times{|row_individ|
					# puts row_individ
					data["individual"] << (1..entries_per_individual).to_a.fill(row_individ)
					@rexp.payload["pheno"].payload.names.map{|name|
						data[name] << (1..entries_per_individual).to_a.fill(@rexp.payload["pheno"].payload[name].to_ruby[row_individ])
					}
					@rexp.payload["geno"].payload.names.map { |chr|
						geno_chr = @rexp.payload["geno"].payload[chr]
						num_markers = geno_chr.payload.first.to_ruby.column_size
						data["chr"] << (1..num_markers).to_a.fill(chr)
						data["genotype"] << geno_chr.payload["data"].to_ruby.row(row_individ).to_a
						data["marker"] << geno_chr.payload["map"].to_ruby.names
						data["markerpos"] << geno_chr.payload["map"].to_a
					}
				}
				# data["chr"].flatten!
				# data["genotype"].flatten!
				data.keys.map{|k| data[k].flatten!}

				#data["refRow"] = observation_labels()
				data
			end
		end
	end
end
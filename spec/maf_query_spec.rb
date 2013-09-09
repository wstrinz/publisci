require_relative '../lib/bio-publisci.rb'
       
#sparql = SPARQL::Client.new("#{repo.uri}/sparql/").query(qry)

class MafQuery
    def generate_data
    	generator = PubliSci::Readers::MAF.new
    	in_file = 'resources/maf_example.maf'
    	f = Tempfile.new('graph')
    	f.close
    	generator.generate_n3(in_file, {output: :file, output_base: f.path})
    	repo = RDF::Repository.load(f.path+'.ttl')
      File.delete(f.path+'.ttl')
    	f.unlink
      repo
    end

    def select_patient_count(repo,patient_id="A8-A08G")
      qry = IO.read('resources/queries/patient.rq')
      qry = qry.gsub('%{patient}',patient_id)
      SPARQL.execute(qry,repo)#[:barcodes].to_i
    end

    def patients(repo)
      qry = IO.read('resources/queries/patient_list.rq')
      SPARQL.execute(qry,repo).map(&:id).map(&:to_s)
    end

    def select_patient_genes(repo,patient_id="A8-A08G")
      qry = IO.read('resources/queries/gene.rq')
      qry = qry.gsub('%{patient}',patient_id)
      SPARQL.execute(qry,repo)
    end

    def select_property(repo,property="hgnc.symbol",patient_id="A8-A08G")
    	qry = IO.read('resources/queries/maf_column.rq').gsub('%{patient}',patient_id).gsub('%{column}',property)
      # puts "#{qry}"
      results = SPARQL.execute(qry,repo).map(&:column).map{|val| 
        if val.is_a?(RDF::URI) and val.to_s["node"]
          node_value(repo,val)
        else
          val
        end

      }.flatten

    end

    def node_value(repo,uri)
      qry = "SELECT DISTINCT ?p ?o where { <#{uri.to_s}> ?p ?o}"
      SPARQL.execute(qry,repo).map{|sol|
        if sol[:p].to_s == "http://semanticscience.org/resource/SIO_000300"
          sol[:o]
        elsif sol[:p].to_s == "http://semanticscience.org/resource/SIO_000008"
          qry = "SELECT DISTINCT ?p ?o where { <#{sol[:o].to_s}> ?p ?o}"
          SPARQL.execute(qry,repo).select{|sol| sol[:p].to_s == "http://semanticscience.org/resource/SIO_000300"}.first[:o]
        elsif sol[:p].to_s != "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
          sol[:o]
        end
      }.reject{|sol| sol == nil}
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

    def gene_length(hugo_symbol)
      hugo_symbol = official_symbol(hugo_symbol.split('/').last)
      qry = IO.read('resources/queries/hugo_to_ensembl.rq').gsub('%{hugo_symbol}',hugo_symbol)
      sparql = SPARQL::Client.new("http://cu.hgnc.bio2rdf.org/sparql")
      sol = sparql.query(qry)

      if sol.size == 0
        raise "No Ensembl entry found for #{hugo_symbol}"
      else
        ensemble_id = sol.map(&:ensembl).first.to_s.split(':').last
      end

      url = URI.parse('http://beta.rest.ensembl.org/')
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new('/lookup/id/' + ensemble_id + '?format=full', {'Content-Type' => 'application/json'})
      response = http.request(request)

      if response.code != "200"
        raise "Invalid response: #{response.code}"
      else
        js = JSON.parse(response.body)
        js['end'] - js['start']
      end
    end

    def patient_info(id,repo)
      symbols = select_property(repo,"Hugo_Symbol",id).map(&:to_s)
      patient_id = select_property(repo,"patient_id",id).first.to_s
      patient = {patient_id: patient_id, mutation_count: symbols.size, mutations:[]}

      symbols.each{|sym| patient[:mutations] << {symbol: sym, length: gene_length(sym)}}
      patient
    end

    def gene_info(id,repo)
      # symbols = select_property(repo,"Hugo_Symbol",id).map(&:to_s)
      # patient_id = select_property(repo,"patient_id",id).first.to_s
      # patient = {patient_id: patient_id, mutation_count: symbols.size, mutations:[]}

      # symbols.each{|sym| patient[:mutations] << {symbol: sym, length: gene_length(sym)}}
      # patient
    end
end

describe MafQuery do
	before(:all) do
    @maf = MafQuery.new
		@repo = @maf.generate_data
	end

    describe "query genes" do
      it { @maf.select_patient_genes(@repo,"BH-A0HP").size.should > 0 }
    end

    describe "query number of entries" do
      it { @maf.select_patient_count(@repo,"BH-A0HP").first[:barcodes].to_s.to_i.should > 0 }
    end


    describe ".patients" do
      it "retrieves a list of patients" do
        @maf.patients(@repo).first.should == "E9-A22B"
      end
    end

    describe ".select_property" do
    	it { @maf.select_property(@repo,"Hugo_Symbol","BH-A0HP").first.to_s.should == "http://identifiers.org/hgnc.symbol/A1CF" }
    	it { @maf.select_property(@repo,"Entrez_Gene_Id","BH-A0HP").first.to_i == 29974 }
    	it { @maf.select_property(@repo,"Center","BH-A0HP").first.to_s.should == "genome.wustl.edu" }
    	it { @maf.select_property(@repo,"NCBI_Build","BH-A0HP").first.to_i.should == 37 }

    	context "extra parsed properties" do
    		it { @maf.select_property(@repo,"sample_id","BH-A0HP").size.should > 0 }
    		it { @maf.select_property(@repo,"patient_id","BH-A0HP").size.should > 0 }
    	end

    	context "non-existant properties" do
    		it { @maf.select_property(@repo,"Chunkiness","BH-A0HP").should == [] }
    	end
    end

    context "remote service calls", no_travis: true do
      describe ".gene_length" do
        it { @maf.gene_length('A2BP1').should == 1694245 }
      end

      # describe ".official_symbol" do
      #   it { @maf.official_symbol('A2BP1').should == 'RBFOX1' }
      # end

      describe ".patient_info" do
        it 'collects the number of mutations and gene lengths for each mutation' do
          patient = @maf.patient_info('BH-A0HP',@repo)
          patient[:mutation_count].should == 1
          patient[:mutations].first[:length].should == 79113
          patient[:mutations].first[:symbol].should == 'http://identifiers.org/hgnc.symbol/A1CF'
        end
      end

      describe ".gene_info" do
        it 'collects the number of patients with a mutation in a gene and its length' do
          patient = @maf.patient_info('BH-A0HP',@repo)
          patient[:mutation_count].should == 1
          patient[:mutations].first[:length].should == 79113
          patient[:mutations].first[:symbol].should == 'http://identifiers.org/hgnc.symbol/A1CF'
        end
      end
    end
end

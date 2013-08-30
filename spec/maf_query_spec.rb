require_relative '../lib/bio-publisci.rb'

class MafQuery
    def generate_data
    	@generator = PubliSci::Readers::MAF.new
    	@in_file = 'resources/maf_example.maf'
    	f = Tempfile.new('graph')
    	f.close
    	@generator.generate_n3(@in_file, nil, :file, f.path)
    	repo = RDF::Repository.load(f.path+'.ttl')
    	f.unlink
    	repo
    end

    def select_patient_count(repo,patient_id="A8-A08G")
      qry = IO.read('resources/queries/patient.rq')
      qry = qry.gsub('%{patient}',patient_id)
      SPARQL.execute(qry,repo)
    end

    def select_patient_genes(repo,patient_id="A8-A08G")
      qry = IO.read('resources/queries/gene.rq')
      qry = qry.gsub('%{patient}',patient_id)
      SPARQL.execute(qry,repo)
    end

    def select_property(repo,property="Hugo_Symbol",patient_id="A8-A08G")
    	qry = IO.read('resources/queries/maf_column.rq').gsub('%{patient}',patient_id).gsub('%{column}',property)
    	SPARQL.execute(qry,repo).map(&:column)
    end
end

class LengthLookup
  require 'net/http'
  require 'uri'
  require 'json'

  def initialize
    @ensembl_server = 'http://beta.rest.ensembl.org/'
    @ensembl_path = '/lookup/id/'
  end

  def hugo_to_ensembl(hugo_id='A2BP1')
    qry = IO.read('resources/queries/hugo_to_ensembl.rq').gsub('%{hugo_symbol}',hugo_id)
    sparql = SPARQL::Client.new("http://cu.hgnc.bio2rdf.org/sparql")
    sol = sparql.query(qry)
    if sol.size == 0
      raise "No Ensembl entry found for #{hugo_id}"
    else
      sol.map(&:ensembl).first.to_s.split(':').last
    end
  end

  def get_length(id='ENSG00000078328')
    url = URI.parse(@ensembl_server)
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(@ensembl_path + id +'?format=full', {'Content-Type' => 'application/json'})
    response = http.request(request)

    if response.code != "200"
      raise "Invalid response: #{response.code}"
    else
      js = JSON.parse(response.body)
      js['end'] - js['start']
    end
  end
end

describe LengthLookup do
  before(:all) do
    @lookup = LengthLookup.new
  end


  describe '.get_length' do
    context 'default arguments' do
      it { @lookup.get_length.should > 0 }
    end
  end

  describe '.hugo_to_ensembl' do
    context 'default arguments' do
      it { @lookup.hugo_to_ensembl('A2BP1').should == 'ENSG00000078328'}
    end
  end
end

describe MafQuery do
	before(:all) do
    @maf = MafQuery.new
		@repo = @maf.generate_data
	end

	  describe "query number of entries" do
	  	it { @maf.select_patient_count(@repo,"BH-A0HP").first[:barcodes].to_s.to_i.should > 0 }
    end
    
    describe "query genes" do
      it { @maf.select_patient_genes(@repo).size.should > 0 }
    end

    describe ".select_property" do
    	it { @maf.select_property(@repo,"Hugo_Symbol","BH-A0HP").size.should > 0 }
    	it { @maf.select_property(@repo,"Entrez_Gene_Id","BH-A0HP").size.should > 0 }
    	it { @maf.select_property(@repo,"Center","BH-A0HP").size.should > 0 }
    	it { @maf.select_property(@repo,"NCBI_Build","BH-A0HP").size.should > 0 }

    	context "extra parsed properties" do
    		it { @maf.select_property(@repo,"sample_id","BH-A0HP").size.should > 0 }
    		it { @maf.select_property(@repo,"patient_id","BH-A0HP").size.should > 0 }
    	end

    	context "non-existant properties" do
    		it { @maf.select_property(@repo,"Chunkiness","BH-A0HP").should == [] }
    	end    	  
    end

    describe 'full example' do
      it 'loads the number of mutations and gene lengths for each mutation' do
        symbols = @maf.select_property(@repo,"Hugo_Symbol","BH-A0HP").map(&:to_s)
        patient_id = @maf.select_property(@repo,"patient_id","BH-A0HP").first.to_s
        patient = {patient_id: patient_id, mutation_count: symbols.size, mutations:[]}
        
        length_lookup = LengthLookup.new

        symbols.each{|sym|
          ensembl_id = length_lookup.hugo_to_ensembl(sym)
          gene_length = length_lookup.get_length(ensembl_id)
          patient[:mutations] << {symbol: sym, length: gene_length}
        }

        patient[:mutation_count].should == 1
        patient[:mutations].first[:length].should == 79113
      end
    end
end

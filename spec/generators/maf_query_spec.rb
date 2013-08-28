require_relative '../../lib/bio-publisci.rb'

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

    end
end

describe MafQuery, no_travis: true do
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

    context ".select_property" do
    	it { @maf.select_property(@repo,"Hugo_Symbol","BH-A0HP").size.should > 0 }
    end
end

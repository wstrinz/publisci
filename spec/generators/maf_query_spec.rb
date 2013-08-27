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
end

describe MafQuery, no_travis: true do
	before(:all) do
    m = MafQuery.new
		@repo = m.generate_data
	end

    it "should query number of entries" do
        m = MafQuery.new
        m.select_patient_count(@repo,"BH-A0HP").first[:barcodes].to_s.to_i.should > 0
    end
    
    it "should query genes" do
        m = MafQuery.new
        m.select_patient_genes(@repo,"BH-A0HP").size.should > 0
    end
end

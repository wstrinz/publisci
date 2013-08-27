require_relative '../../lib/bio-publisci.rb'

class MafQuery
  def select_patient(patient_id="A8-A08G")
    @generator = PubliSci::Readers::MAF.new
    @in_file = 'resources/maf_example.maf'
    f = Tempfile.new('graph')
    f.close
    @generator.generate_n3(@in_file, nil, :file, f.path)
    str = IO.read(f.path+'.ttl')
    qry = IO.read('resources/queries/patient.rq')
    qry = qry.gsub('%{patient}',patient_id)
    repo = RDF::Repository.load(f.path+'.ttl')
    f.unlink
    SPARQL.execute(qry,repo)
  end
end

describe MafQuery do
  it "should query", no_travis: true do
    m = MafQuery.new
    m.select_patient("BH-A0HP").size.should > 0
  end
end
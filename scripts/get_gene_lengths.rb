require_relative '../lib/bio-publisci.rb'
def gene_lengths(repo)
  sadi_in = <<-EOF
  @prefix sio: <http://semanticscience.org/resource/>.
  @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
  @prefix serviceowl: <http://biordf.org:8080/sadi_service_ontologies/HUGO_2_ENSEMBLGENEINFO.owl/>.

  EOF
  templ = <<-EOF

  EOF

  gene_query = <<-EOF
  PREFIX qb:   <http://purl.org/linked-data/cube#>

  SELECT DISTINCT ?gene WHERE {
    ?obs a qb:Observation;
      <http://onto.strinz.me/properties/Hugo_Symbol> ?gene.
  }
  EOF

  genes = PubliSci::QueryHelper.execute(gene_query,repo).map(&:gene)
  puts genes.size
  genes[0..20].each{|gene|
    sadi_in += <<-EOF
    <#{gene}> a serviceowl:HUGO_2_ENSEMBLGENEINFO_Input;
       sio:SIO_000300 "#{gene}".
    EOF
  }
  open('sadi_in.ttl','w'){|f| f.write sadi_in}
  # sadi_in = IO.read('sadi_in.ttl')
  # response = SADI_request.send_request('http://biordf.org:8080/cgi-bin/services/HUGO_2_ENSEMBLGENEINFO_sync.pl',sadi_in)
  response = PubliSci::SADI_request.fetch_async('http://biordf.org:8080/cgi-bin/services/HUGO_2_ENSEMBLGENEINFO_async.pl',sadi_in)
  response.join("\n\n")
  # open('gene_lengths.ttl','w'){|f| f.write response.join("\n\n")}
end

# unless ARGV[0]
  open('gene_lengths.ttl','w'){|f| f.write gene_lengths(RDF::FourStore::Repository.new('http://localhost:8080'))}

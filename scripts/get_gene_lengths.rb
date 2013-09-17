# require_relative '../lib/bio-publisci.rb'
require 'bio-publisci'
def gene_lengths(repo)

  gene_query = <<-EOF
  PREFIX qb:   <http://purl.org/linked-data/cube#>

  SELECT DISTINCT ?gene WHERE {
    ?obs a qb:Observation;
      <http://onto.strinz.me/properties/Hugo_Symbol> ?gene.
  }
  EOF

  genes = PubliSci::QueryHelper.execute(gene_query,repo).map(&:gene)
  puts "retrieving information for #{genes.size} genes"

  all_genes = []
  genes.each_slice(250){|slice|
    sadi_in = <<-EOF
    @prefix sio: <http://semanticscience.org/resource/>.
    @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
    @prefix serviceowl: <http://biordf.org:8080/sadi_service_ontologies/HUGO_2_ENSEMBLGENEINFO.owl/>.

    EOF

    slice.each{|gene|
      sadi_in += <<-EOF
      <#{gene}> a serviceowl:HUGO_2_ENSEMBLGENEINFO_Input;
         sio:SIO_000300 "#{gene}".
      EOF
    }
    response = PubliSci::SADI_request.fetch_async('http://biordf.org:8080/cgi-bin/services/HUGO_2_ENSEMBLGENEINFO_async.pl',sadi_in)
    puts "chunk done #{ all_genes.size}"
    all_genes << response.join("\n\n")
  }
  all_genes.join("\n\n")
end

repo_uri = ARGV[0] || 'http://localhost:8080'

repo = RDF::FourStore::Repository.new(repo_uri)

lengths = gene_lengths(repo)
puts lengths
if ARGV[1] == "save"
  repo << RDF::Turtle::Reader.new(lengths)
else
  open('gene_lengths.ttl','w'){|f| f.write lengths }
end


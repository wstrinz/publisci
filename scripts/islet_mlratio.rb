load File.dirname(__FILE__) + '/../lib/bio-publisci.rb'

gen = R2RDF::Reader::RMatrix.new
con = Rserve::Connection.new
con.eval("load('#{ARGV[0] || './.RData'}')")
gen.generate_n3(con, "islet.mlratio", "pheno", {measures: ["probe","individual","pheno"], no_labels: true})

load File.dirname(__FILE__) + '/../lib/publisci.rb'

gen = PubliSci::Readers::RMatrix.new
con = Rserve::Connection.new
con.eval("load('#{ARGV[0] || './.RData'}')")
gen.generate_n3(con, "islet.mlratio", "pheno", {measures: ["probe","individual","pheno"], no_labels: true})

load File.dirname(__FILE__) + '/../lib/bio-publisci.rb'

gen = PubliSci::Reader::RMatrix.new
con = Rserve::Connection.new
con.eval("load('#{ARGV[0] || './.RData'}')")
gen.generate_n3(con, "scan.islet", "scan", {measures: ["probe","marker","lod"], no_labels: true})

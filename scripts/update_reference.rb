puts "Really rewrite reference files? This could mess up the tests... [y/N]"
exit unless gets.chomp == 'y'

puts "overwriting #{File.absolute_path(File.dirname(__FILE__) + '/../spec/turtle/bacon')}"
load File.dirname(__FILE__) + '/../lib/publisci.rb'

gen = PubliSci::Readers::CSV.new
turtle_string = gen.generate_n3(File.dirname(__FILE__) + '/../spec/csv/bacon.csv','bacon',{dimensions:["producer","pricerange"], label_column:0})
open(File.dirname(__FILE__) + '/../spec/turtle/bacon', 'w'){|f| f.write turtle_string}

rcon = Rserve::Connection.new
gen = PubliSci::Readers::Dataframe.new
rcon.void_eval <<-EOF
library(qtl)
data(listeria)
mr = scanone(listeria,method="mr")
EOF
rexp = rcon.eval 'mr'
turtle_string = gen.generate_n3(rexp,'mr')
open(File.dirname(__FILE__) + '/../spec/turtle/reference', 'w'){|f| f.write turtle_string}
puts "overwriting #{File.absolute_path(File.dirname(__FILE__) + '/../spec/turtle/reference')}"

turtle_string = PubliSci::Dataset.for('resources/weather.numeric.arff',false)
open(File.dirname(__FILE__) + '/../spec/turtle/weather', 'w'){|f| f.write turtle_string}
puts "overwriting #{File.absolute_path(File.dirname(__FILE__) + '/../spec/turtle/weather')}"
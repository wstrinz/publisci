require 'bio-band'
require 'publisci'

f = open(File.dirname(__FILE__) + '/../resources/weather.numeric.arff')
clustering = Weka::Clusterer::SimpleKMeans::Base
clustering.set_options "-N 5"
clustering.set_data(Core::Parser::parse_ARFF(f.path))
clustered = clustering.new
puts clustered
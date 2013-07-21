Then(/^I should be able to cluster the result and print statistics$/) do
  require 'ruby_mining'
  f=Tempfile.open('arff'); f.write @result; f.close
  clustering = Weka::Clusterer::SimpleKMeans::Base
  clustering.set_options "-N 5"
  clustering.set_data(Core::Parser::parse_ARFF(f.path))
  f.unlink
  clustered = clustering.new
  puts clustered
end
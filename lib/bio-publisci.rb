# This is temporary, just to help w/ development so I don't have to rewrite r2rdf.rb to be
# a standard gem base yet. Also load s the files instead of require for easy reloading
require 'tempfile'
require 'rdf'
require 'csv'
require 'rserve'
require 'sparql'
require 'sparql/client'
require 'rdf/turtle'

def load_folder(folder)
	Dir.foreach(File.dirname(__FILE__) + "/#{folder}") do |file|
		unless file == "." or file == ".."
			load File.dirname(__FILE__) + "/#{folder}/" + file
		end
	end
end

# load File.dirname(__FILE__) + '/bio-publisci/dataset/interactive.rb'
load File.dirname(__FILE__) + '/bio-publisci/query/query_helper.rb'
load File.dirname(__FILE__) + '/bio-publisci/parser.rb'
load File.dirname(__FILE__) + '/bio-publisci/r_client.rb'
load File.dirname(__FILE__) + '/bio-publisci/analyzer.rb'
load File.dirname(__FILE__) + '/bio-publisci/store.rb'
load File.dirname(__FILE__) + '/bio-publisci/dataset/data_cube.rb'
load File.dirname(__FILE__) + '/bio-publisci/dataset/dataset_for.rb'


load_folder('bio-publisci/metadata')
load_folder('bio-publisci/readers')
load_folder('bio-publisci/writers')
load_folder('bio-publisci/dataset/ORM')
# Dir.foreach(File.dirname(__FILE__) + '/generators') do |file|
# 	unless file == "." or file == ".."
# 		load File.dirname(__FILE__) + '/generators/' + file
# 	end
# end
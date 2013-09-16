# This is temporary, just to help w/ development so I don't have to rewrite r2rdf.rb to be
# a standard gem base yet. Also load s the files instead of require for easy reloading
require 'tempfile'
require 'fileutils'
require 'csv'

require 'rdf'
require 'sparql'
require 'sparql/client'
require 'rdf/turtle'
require 'rdf/rdfxml'
require 'json/ld'

require 'rserve'

begin
	require 'spira'
rescue LoadError
	puts "can't load spira; orm unavailable"
end

def load_folder(folder)
	Dir.foreach(File.dirname(__FILE__) + "/#{folder}") do |file|
		unless file == "." or file == ".."
			f = File.dirname(__FILE__) + "/#{folder}/" + file
      load f unless File.directory?(f)
		end
  end
end

load_folder('bio-publisci/mixins')

load File.dirname(__FILE__) + '/bio-publisci/dataset/interactive.rb'
load File.dirname(__FILE__) + '/bio-publisci/query/query_helper.rb'
load File.dirname(__FILE__) + '/bio-publisci/parser.rb'
load File.dirname(__FILE__) + '/bio-publisci/post_processor.rb'
load File.dirname(__FILE__) + '/bio-publisci/r_client.rb'
load File.dirname(__FILE__) + '/bio-publisci/analyzer.rb'
load File.dirname(__FILE__) + '/bio-publisci/store.rb'
load File.dirname(__FILE__) + '/bio-publisci/dataset/data_cube.rb'
load File.dirname(__FILE__) + '/bio-publisci/dataset/dataset_for.rb'
load File.dirname(__FILE__) + '/bio-publisci/dataset/configuration.rb'
load File.dirname(__FILE__) + '/bio-publisci/dataset/dataset.rb'
load File.dirname(__FILE__) + '/bio-publisci/datacube_model.rb'
load File.dirname(__FILE__) + '/bio-publisci/output.rb'
load File.dirname(__FILE__) + '/bio-publisci/metadata/prov/element.rb'
load File.dirname(__FILE__) + '/bio-publisci/metadata/prov/prov.rb'
load File.dirname(__FILE__) + '/bio-publisci/writers/base.rb'
load File.dirname(__FILE__) + '/bio-publisci/readers/base.rb'


load_folder('bio-publisci/dsl')
load_folder('bio-publisci/metadata')
load_folder('bio-publisci/metadata/prov')
load_folder('bio-publisci/metadata/prov/model')
load_folder('bio-publisci/readers')
load_folder('bio-publisci/writers')
load_folder('bio-publisci/dataset/ORM')
# Dir.foreach(File.dirname(__FILE__) + '/generators') do |file|
	# unless file == "." or file == ".."
# 		load File.dirname(__FILE__) + '/generators/' + file
# 	end
# end

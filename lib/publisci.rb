# This is temporary, just to help w/ development so I don't have to rewrite r2rdf.rb to be
# a standard gem base yet. Also load s the files instead of require for easy reloading
require 'tempfile'
require 'fileutils'
require 'csv'

require 'spira'

require 'rdf'
require 'sparql'
require 'sparql/client'
require 'rdf/turtle'
require 'rdf/rdfxml'
require 'json/ld'

require 'rserve'
require 'rest-client'

# begin
# 	require 'spira'
# rescue LoadError
# 	puts "can't load spira; orm unavailable"
# end

def load_folder(folder)
	Dir.foreach(File.dirname(__FILE__) + "/#{folder}") do |file|
		unless file == "." or file == ".."
			f = File.dirname(__FILE__) + "/#{folder}/" + file
      load f unless File.directory?(f)
		end
  end
end

load_folder('publisci/mixins')
load File.dirname(__FILE__) + '/publisci/parser.rb'
load File.dirname(__FILE__) + '/publisci/dataset/interactive.rb'

load File.dirname(__FILE__) + '/publisci/dataset/data_cube.rb'
load File.dirname(__FILE__) + '/publisci/dataset/dataset_for.rb'
load File.dirname(__FILE__) + '/publisci/dataset/configuration.rb'
load File.dirname(__FILE__) + '/publisci/dataset/dataset.rb'

load File.dirname(__FILE__) + '/publisci/generators/base.rb'
load File.dirname(__FILE__) + '/publisci/parsers/base.rb'
load_folder('publisci/parsers')
load_folder('publisci/generators')

load File.dirname(__FILE__) + '/publisci/query/query_helper.rb'
load File.dirname(__FILE__) + '/publisci/post_processor.rb'
load File.dirname(__FILE__) + '/publisci/analyzer.rb'
load File.dirname(__FILE__) + '/publisci/store.rb'
load File.dirname(__FILE__) + '/publisci/datacube_model.rb'
load File.dirname(__FILE__) + '/publisci/output.rb'
load File.dirname(__FILE__) + '/publisci/metadata/prov/element.rb'
load File.dirname(__FILE__) + '/publisci/metadata/prov/prov.rb'
load File.dirname(__FILE__) + '/publisci/writers/base.rb'
load File.dirname(__FILE__) + '/publisci/readers/base.rb'


load_folder('publisci/dsl')
load_folder('publisci/metadata')
load_folder('publisci/metadata/prov')
load_folder('publisci/metadata/prov/model')
load_folder('publisci/readers')
load_folder('publisci/writers')
load_folder('publisci/dataset/ORM')
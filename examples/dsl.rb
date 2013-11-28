require 'publisci'
include PubliSci::DSL

# Specify input data
# Not that every statement in the datablock is essentially declarative;
#  since the generator won't be run until the end of the block, you can
#  specify input parameters in any order.

data do
  # use local or remote paths
  # The gem will determine which transformer to use for your input data based
  # on the file's extension
  source 'https://github.com/wstrinz/publisci/raw/master/spec/csv/bacon.csv'

  # specify datacube properties
  # see http://www.w3.org/TR/vocab-data-cube/#cubes-model
  dimension 'producer', 'pricerange'
  measure 'chunkiness'

  # set transformer options
  # These will generally be parameters relevant only to a certain input type
  # In this case, we're using the "producer" column to label each operation.
  option 'label_column', 'producer'
end

# Describe dataset
metadata do
  dataset 'bacon'
  title 'Bacon dataset'
  creator 'Will Strinz'
  description 'some data about bacon'
  date '1-10-2010'
end

# Send output to an RDF::Repository
#  can also use 'generate_n3' to output a turtle string
repo = to_repository

# run SPARQL queries on the dataset
PubliSci::QueryHelper.execute('select * where {?s ?p ?o} limit 5', repo)

# export in other formats
PubliSci::Writers::ARFF.new.from_store(repo)

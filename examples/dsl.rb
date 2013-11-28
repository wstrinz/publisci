require 'publisci'
include PubliSci::DSL

# Specify input data
data do
  # use local or remote paths
  source 'https://github.com/wstrinz/publisci/raw/master/spec/csv/bacon.csv'

  # specify datacube properties
  dimension 'producer', 'pricerange'
  measure 'chunkiness'

  # set parser specific options
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

# PubliSci

[![Build Status](https://secure.travis-ci.org/wstrinz/bioruby-publisci.png)](http://travis-ci.org/wstrinz/publisci)

Full description goes here

Note: this software is under active development!

## Installation

```sh
gem install publisci
```

## Usage

```ruby
require 'publisci'
include PubliSci::DSL

data do
  object 'https://github.com/wstrinz/publisci/raw/master/spec/csv/bacon.csv' # => local or remote path
  dimension 'producer', 'pricerange'                                         # => specify datacube properties
  measure 'chunkiness'

  option 'label_column', 'producer'                                          # => set parser specific options
end

metadata do                                                                  # => describe metadata
  dataset 'bacon'
  title 'Bacon dataset'
  creator 'Will Strinz'
  description 'some data about bacon'
  date '1-10-2010'
end

repo = to_repository                                                          # => send output to an RDF::Repository
                                                                              # => can also use 'generate_n3' to output plain turtle

PubliSci::QueryHelper.execute('select * where {?s ?p ?o} limit 5', repo)      # => run SPARQL queries on the dataset

PubliSci::Writers::ARFF.new.from_store(repo)                                     # => export using other formats
```



The API doc is online. For more code examples see the test files in
the source tree.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/wstrinz/bioruby-publisci

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

If you use this software, please cite

* [The Ruby Science Foundation. 2013. SciRuby: Tools for scientific computing in Ruby. http://sciruby.com.](http://sciruby.com)

and one of

* [BioRuby: bioinformatics software for the Ruby programming language](http://dx.doi.org/10.1093/bioinformatics/btq475)
* [Biogem: an effective tool-based approach for scaling up open source software development in bioinformatics](http://dx.doi.org/10.1093/bioinformatics/bts080)

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#publisci)

## Copyright

Copyright (c) 2013 wstrinz. See LICENSE.txt for further details.


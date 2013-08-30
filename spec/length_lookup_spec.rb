require_relative '../lib/bio-publisci.rb'
require 'net/http'
require 'uri'
require 'json'

class LengthLookup

  def initialize
    @ensembl_server = 'http://beta.rest.ensembl.org/'
    @ensembl_path = '/lookup/id/'
  end

  def hugo_to_ensemble(hugo_id='A2BP1')
    qry = IO.read('resources/queries/hugo_to_ensembl.rq').gsub('%{hugo_symbol}',hugo_id)
    sparql = SPARQL::Client.new("http://cu.hgnc.bio2rdf.org/sparql")
    sol = sparql.query(qry)
    if sol.size == 0
      raise "No Ensembl entry found for #{hugo_id}"
    else
      sol.map(&:ensembl).first.to_s.split(':').last
    end
  end

  def get_length(id='ENSG00000078328')
    url = URI.parse(@ensembl_server)
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(@ensembl_path + id +'?format=full', {'Content-Type' => 'application/json'})
    response = http.request(request)

    if response.code != "200"
      raise "Invalid response: #{response.code}"
    else
      js = JSON.parse(response.body)
      js['end'] - js['start']
    end
  end
end

describe LengthLookup do
  before(:all) do
    @lookup = LengthLookup.new
  end


  describe '.get_length' do
    context 'default arguments' do
      it { @lookup.get_length.should > 0 }
    end
  end

  describe '.hugo_to_ensemble' do
    context 'default arguments' do
      it { @lookup.hugo_to_ensemble('A2BP1').should == 'ENSG00000078328'}
    end
  end
end

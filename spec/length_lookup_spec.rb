require_relative '../lib/bio-publisci.rb'
require 'net/http'
require 'uri'
require 'json'

class LengthLookup

	def initialize
		@server = 'http://beta.rest.ensembl.org/'
		@get_path = '/lookup/id/'
	end

	def hugo_to_ensemble(hugo_id='A2BP1')
		
	end

	def get_length(id='ENSG00000157764')
		url = URI.parse(@server)
		http = Net::HTTP.new(url.host, url.port)
		request = Net::HTTP::Get.new(@get_path+id+'?format=full', {'Content-Type' => 'application/json'})
		response = http.request(request)

		if response.code != "200"
		  raise "Invalid response: #{response.code}"
		else
			puts response.body
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
end

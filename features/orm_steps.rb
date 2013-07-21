require_relative '../lib/bio-publisci.rb'

Given /^an ORM::DataCube entitled "(.*?)"$/ do |name|
	@cube = R2RDF::Dataset::ORM::DataCube.new(name: name)
end

Given /^an ORM::DataCube entitled "(.*?)" with the following options:$/ do |name, opts|
	options_hash = {name: name}
	opts.hashes.map{|hash|
		k = hash["key"]
		k = k[1..-1].to_sym if k[0] == ":"

		v = hash["value"]
		v = v[1..-1].to_sym if k[0] == ":"
		
		v = true if v =="true"
		v = false if v =="false"

		options_hash[k] = v
	}
	@cube = R2RDF::Dataset::ORM::DataCube.new(options_hash)
end

Given(/^a turtle string from file (.*)$/) do |file|
	@string = IO.read(file)
end

Given(/^the URI string "(.*?)"$/) do |uri|
  @string = uri
end

When(/^I call the ORM::DataCube class method load on it$/) do
  @cube = R2RDF::Dataset::ORM::DataCube.load(@string)
end

When /^I add a "(.*?)" dimension$/ do |dim|
	@cube.add_dimension(dim)
end

When /^I add a "(.*?)" measure$/ do |meas|
	@cube.add_measure(meas)
end

When /^I add the observation (.*)$/ do |obs|
	data = eval(obs)
	# obs.split(',').map{|entry| data[entry.chomp.strip.split(':')[0].to_s] = eval(entry.chomp.strip.split(':')[1])}
	@cube.add_observation(data)
end

When /^adding the observation (.*) should raise error (.*)$/ do |obs,err|
	data = eval(obs)
	expect { @cube.add_observation(data) }.to raise_error(err)
end

When /^I call the cubes (.*) method with the arguments (.*)$/ do |method,args|
  eval("args = #{args}")
  @cube.send(method.to_sym, *args)
end

Then /^the to_n3 method should return a string$/ do
	@cube.to_n3.is_a?(String).should be true
end

Then /^the to_n3 method should raise error (.*?)$/ do |err|
	expect { @cube.to_n3 }.to raise_error(err)
end

Then /^the to_n3 method should return a string with a "(.*?)"$/ do |search|
	@cube.to_n3[search].should_not be nil
end

Then(/^I should receive an ORM::DataCube object$/) do
  @cube.is_a?(R2RDF::Dataset::ORM::DataCube).should == true
end

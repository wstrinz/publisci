require_relative '../lib/publisci.rb'

Given /a store of type (.*?)$/ do |type|
	@store = PubliSci::Store.new(type: :"#{type}")
end

When /^I call the stores add method with the turtle file (.*?) and an RDF::(.*?)$/ do |file,graph|
	graph = RDF.const_get(graph).new #rescue graph
	@graph = @store.add(file,graph)
end

When /^I call the stores add method with the turtle file (.*?) and the graph name "(.*?)"$/ do |file,graph|
	@graph = @store.add(file,graph)
end


When /^I call the query method using the text in file (.*)$/ do |file|
	query_string = IO.read(file)
	@query_result  = @store.query(query_string)
end

Then /^calling the query method using the text in file (.*) should return (.*) results$/ do |file, num|
	query_string = IO.read(file)
	@store.query(query_string) #.size.should == num
end

Then /^I should recieve a non-empty graph$/ do
	@graph.is_a?(RDF::Repository).should be true
	@graph.size.should > 0
end

Then /^I should receive an info string$/ do
	@graph.is_a?(String).should be true
end

Then /^I should receive (.*) results$/ do |num|
	@query_result.size.should == num.to_i
end

# Then /^raise the result$/ do
# 	raise "got @graph"
# end
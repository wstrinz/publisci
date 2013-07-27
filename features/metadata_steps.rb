Given(/^a class which includes the Metadata module$/) do
  class Meta
    include R2RDF::Metadata
  end
  @klass = Meta
end

Given(/^the source object (\{.+\})$/) do |fields|
  @original = eval(fields)
end

Given(/^the rdf dataset (\{.+\})$/) do |fields|
  @rdf = eval(fields)
end

When(/^I call its provenance method with the source object and the rdf object$/) do
  @response = @klass.new.provenance(@original, @rdf, nil)
end

When(/^I call its basic method with the hash (\{.+\})$/) do |fields|
  fields = eval(fields)
  @response = @klass.new.basic(fields)
end

When(/^I call its provenance method with the hash (\{.+\})$/) do |fields|
  fields = eval(fields)
  @response = @klass.new.provenance(fields)
end

Then(/^I should receive a metadata string$/) do
  @response.is_a?(String).should be true
  puts @response
end

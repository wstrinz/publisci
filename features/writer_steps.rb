Given(/^a (.*) writer$/) do |type|
  @writer = R2RDF::Writer.const_get(type).new
end

When(/^I call its from_turtle method on the file (.*)$/) do |file|
  @result = @writer.from_turtle(file)
end

When(/^I call its from_turtle method on the turtle string$/) do
  f=Tempfile.open('writerttl'); f.write @turtle_string; f.close
  @result = @writer.from_turtle(f.path)
  f.unlink
end

Then(/^I should receive a \.arff file as a string$/) do
  @result.is_a?(String).should be true
end

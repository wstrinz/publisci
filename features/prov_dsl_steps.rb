Given(/^the prov DSL string from file (.+)$/) do |file|
  @dsl_string = IO.read(file)
end

When(/^I call Prov\.run on it$/) do
  @turtle_string = Prov.run(@dsl_string)
end

Then(/^I should receive a provenance string$/) do
  puts @turtle_string
end
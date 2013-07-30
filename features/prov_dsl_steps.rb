Given(/^the prov DSL string from file (.+)$/) do |file|
  @dsl_string = file
end

When(/^I call Prov\.run on it$/) do
  @turtle_string = PubliSci::Prov.run(@dsl_string)
end

Then(/^I should receive a provenance string$/) do
  puts @turtle_string
end
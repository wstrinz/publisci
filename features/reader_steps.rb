require_relative '../lib/publisci.rb'

Given /^a (.*) generator$/ do |generator|
	@generator = PubliSci::Readers.const_get(generator).new
end

When /^I ask for its methods$/ do
	@methods = @generator.methods
end

When /^I provide an R (.*) and the label "(.*?)"$/ do |type, label|
	if type == "dataframe"
		r = Rserve::Connection.new
		r.eval <<-EOF
			library(qtl)
			data(listeria)
			mr = scanone(listeria,method="mr")
EOF
		rexp = r.eval 'mr'
		@attr = rexp,label
	else
		raise "Unknown object #{type}"
	end

end

When /^I provide the.* file (.*) and the label "(.*?)"$/ do |file, label|
	raise "Cant find #{file}" unless File.exist? file
	@attr = file,label
end

When /^I provide the.* file (.*) and the label "(.*?)" and the options (.*)$/ do |file, label, opts|
  raise "Cant find #{file}" unless File.exist? file
  @attr = file,label,eval(opts)
end

When /^I provide the.* file (\S+)$/ do |file|
	raise "Cant find #{file}" unless File.exist? file
	@attr = file
end

When /^generate a turtle string from it$/ do
	@turtle_string = @generator.send :generate_n3, *@attr
	# open('weather.ttl','w'){|f| f.write @turtle_string}
end

Then /^I should have access to a (.*) method$/ do |method|
	@methods.include?(method).should == true
end

Then /^I should be able to call its (.*) method$/ do |method|
	@generator.methods.include?(:"#{method}").should == true
end

Then /^the result should contain a "(.*?)"$/ do |search|
	@turtle_string[search].should_not be nil
end

Then /^the result should contain some "(.*?)"s$/ do |search|
	@turtle_string[search].size.should > 1
end
# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "bio-publisci"
  gem.homepage = "http://github.com/wstrinz/bioruby-publisci"
  gem.license = "MIT"
  gem.summary = %Q{Publish science data using semantic web ontologies}
  gem.description = %Q{A toolkit for publishing scientific results and datasets using RDF and related technologies }
  gem.email = "wstrinz@gmail.com"
  gem.authors = ["wstrinz"]
  gem.version = "0.0.2"
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

# task :default => :spec

task :default => [] do
  begin   
    Rake::Task[:spec].invoke
  rescue
  end
  Rake::Task[:features].invoke
end

task :test => [] do
  begin   
    Rake::Task[:spec].invoke
  rescue
  end
  Rake::Task[:features].invoke
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : "0.0.1"

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bio-publisci #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

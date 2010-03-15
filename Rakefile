require 'rubygems'
require 'rake'
require 'jeweler'
require 'rake/testtask'
require 'rake/rdoctask'

Jeweler::Tasks.new do |gem|
  gem.name = "bivy"
  gem.summary = %Q{roll your own citation manager (if you like that sort of thing)}
  gem.description = %Q{uses a simple YAML format to store bibliographies.  Then modifies citations in openoffice and outputs a bibliography (in different forms) for inclusion in the document}
  gem.email = "jtprince@gmail.com"
  gem.homepage = "http://github.com/jtprince/bivy"
  gem.authors = ["John Prince"]
  gem.add_development_dependency "spec-more", ">= 0"
  # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
end

# test
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

#require 'rcov/rcovtask'
#Rcov::RcovTask.new do |spec|
#  spec.libs << 'spec'
#  spec.pattern = 'spec/**/*_spec.rb'
#  spec.verbose = true
#end

task :spec => :check_dependencies

task :default => :spec

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bivy #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

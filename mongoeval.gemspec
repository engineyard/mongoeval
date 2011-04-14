# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mongoeval/version"

Gem::Specification.new do |s|
  s.name        = "mongoeval"
  s.version     = MongoEval::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Schmitz, Ines Sombra"]
  s.email       = ["mschmitz@engineyard.com", "isombra@engineyard.com"]
  s.homepage    = ""
  s.summary     = %q{MongoDB evaluation.}
  s.description = %q{Quick tests for MongoDB in various failure scenarios.}

  s.rubyforge_project = "mongoeval"
  
  s.add_dependency('mongo', '>= 1.3.0')
  s.add_dependency('bson_ext', '>= 1.3.0')
  s.add_dependency('rspec')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

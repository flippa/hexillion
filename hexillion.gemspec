# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hexillion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Louis Simoneau"]
  gem.email         = ["simoneau.louis@gmail.com"]
  gem.description   = %q{Hexillion WhoIs API Client for Ruby}
  gem.summary       = %q{Provides a simple client for the Hexillion API}
  gem.homepage      = ''
  
  gem.add_dependency "rest-client", "~> 1.6.3"
  gem.add_dependency "nokogiri",    "~> 1.5.0"
  
  gem.add_development_dependency "rspec", "~> 2.6"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "hexillion"
  gem.require_paths = ['lib']
  gem.version       = Hexillion::VERSION
end

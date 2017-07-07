# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hexillion/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Flippa Developers"]
  gem.email         = ["developers@flippa.com"]
  gem.description   = %q{Hexillion WhoIs API Client for Ruby}
  gem.summary       = %q{Provides a simple client for the Hexillion API}
  gem.homepage      = ''

  gem.add_dependency "nokogiri", ">= 1.5"

  gem.add_development_dependency "rspec", "~> 3.6"
  gem.add_development_dependency "rake"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "hexillion"
  gem.require_paths = ['lib']
  gem.version       = Hexillion::VERSION
end

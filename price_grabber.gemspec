# -*- encoding: utf-8 -*-
require File.expand_path('../lib/price_grabber/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Matt Scott", "Jason Leonard"]
  gem.email         = ["scoma@musc.edu"]
  gem.description   = %q{Obtains pricing and rate data from obis-common}
  gem.summary       = %q{Gem takes effective dates of pricing maps and pricing setups into account to produce accurate service rates based on funding source}
  gem.homepage      = "https://github.com/HSSC/price_grabber"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "price_grabber"
  gem.require_paths = ["lib"]
  gem.version       = PriceGrabber::VERSION
  
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "simplecov"

  gem.add_runtime_dependency "rest-client"
  gem.add_runtime_dependency "json"
end

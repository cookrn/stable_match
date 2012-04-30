# -*- encoding: utf-8 -*-
require File.expand_path('../lib/stable_match/version', __FILE__)

Gem::Specification.new do | gem |
  gem.authors       = [ "Ryan Cook" ]
  gem.email         = [ "cookrn@gmail.com" ]
  gem.description   = %q{A generic implementation of the stable match algorightm.}
  gem.summary       = %q{stable_match v0.1.0}
  gem.homepage      = "https://github.com/cookrn/stable_match"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "stable_match"
  gem.require_paths = [ "lib" ]
  gem.version       = StableMatch::VERSION

## Runtime Dependencies
#
  gem.add_dependency "fattr" , "~> 2.2.1"
  gem.add_dependency "map"   , "~> 5.5.0"

## Development Dependencies
#
  gem.add_development_dependency "minitest" , "~> 2.12.1"
  gem.add_development_dependency "rake"     , "~> 0.9.2.2"
  gem.add_development_dependency "rego"     , "~> 1.0.0"
end

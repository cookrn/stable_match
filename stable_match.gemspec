# -*- encoding: utf-8 -*-
require File.expand_path('../lib/stable_match/version', __FILE__)

Gem::Specification.new do | gem |
  gem.authors       = [ 'Ryan Cook' , 'Ara Howard' ]
  gem.email         = [ 'cookrn@gmail.com' , 'ara.t.howard@gmail.com' ]
  gem.description   = %q{A generic implementation of the stable match algorightm.}
  gem.summary       = %q{stable_match v0.1.0}
  gem.homepage      = 'https://github.com/cookrn/stable_match'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'stable_match'
  gem.require_paths = [ 'lib' ]
  gem.version       = StableMatch::VERSION

  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'rake'
end

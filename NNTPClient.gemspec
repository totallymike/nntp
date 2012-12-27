# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'NNTPClient/version'

Gem::Specification.new do |gem|
  gem.name          = "NNTPClient"
  gem.version       = NNTPClient::VERSION
  gem.authors       = ["Michael Westbom"]
  gem.email         = %w(totallymike@gmail.com)
  gem.description   = %q{Gem to handle basic NNTP usage}
  gem.summary       = %q{NNTP Client}
  gem.homepage      = ""
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w(lib)

  gem.add_development_dependency "rake"
end

# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'active_sanity/version'

Gem::Specification.new do |s|
  s.name        = 'active_sanity'
  s.version     = ActiveSanity::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Philippe Creux']
  s.email       = ['pcreux@gmail.com']
  s.summary     = 'Checks Sanity of Active Record records'
  s.description = 'Performs a Sanity Check of your database by logging all invalid Active Records'
  s.homepage    = 'https://github.com/pcreux/active_sanity'

  s.add_dependency 'rails', '>=5.0'

  s.add_development_dependency 'rails', '~>6.0'
  s.add_development_dependency 'rspec', '~>3.1'
  s.add_development_dependency 'cucumber', '~>1.3'
  s.add_development_dependency 'sqlite3', '~>1.3'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "stringglob/version"

Gem::Specification.new do |s|
  s.name        = "stringglob"
  s.version     = StringGlob::VERSION
  s.authors     = ["SATOH Fumiyasu"]
  s.email       = ["fumiyas@osstech.co.jp"]
  s.homepage    = "https://github.com/fumiyas/ruby-stringglob"
  s.summary     = %q{Generate a Regexp object from a glob(3) pattern}
  s.description = %q{Generate a Regexp object from a glob(3) pattern}

  s.rubyforge_project = "stringglob"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

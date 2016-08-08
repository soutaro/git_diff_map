# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git_diff_map/version'

Gem::Specification.new do |spec|
  spec.name          = "git_diff_map"
  spec.version       = GitDiffMap::VERSION
  spec.authors       = ["Soutaro Matsumoto"]
  spec.email         = ["matsumoto@soutaro.com"]

  spec.summary       = %q{Maps line from old version to new version.}
  spec.description   = %q{Maps line from old version to new version.}
  spec.homepage      = "https://github.com/soutaro/git_diff_map"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.licenses = ['MIT']

  spec.add_runtime_dependency 'git_diff_parser', '~> 2.3.0'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.9.0"
end

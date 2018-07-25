# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-external-pod-sorter/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-external-pod-sorter'
  spec.version       = CocoapodsExternalPodSorter::VERSION
  spec.authors       = ['tripleCC']
  spec.email         = ['triplec.linux@gmail.com']
  spec.description   = %q{对 Podfile 中依赖 external 的组件进行分组.}
  spec.summary       = %q{对 Podfile 中依赖 external 的组件进行分组.}
  spec.homepage      = 'https://github.com/tripleCC/cocoapods-external-pod-sorter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end

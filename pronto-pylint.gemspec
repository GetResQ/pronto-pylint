
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pronto/pylint/version'

Gem::Specification.new do |spec|
  spec.name = 'pronto-pylint'
  spec.version = Pronto::PylintVersion::VERSION
  spec.authors = ['Bob Reid']
  spec.email = ['breid@getresq.com']

  spec.summary = <<-SUMMARY
    Pronto runner for Pylint
  SUMMARY
  spec.homepage = 'https://www.github.com/GetResQ/pronto-pylint'
  spec.license = 'MIT'

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.test_files = []
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2.0'

  spec.add_runtime_dependency('pronto', '>=0.9.0', '<1.0')

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'pry'
end

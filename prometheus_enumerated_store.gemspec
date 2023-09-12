$:.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'prometheus/enumerated_store/version'

Gem::Specification.new 'prometheus_enumerated_store' do |spec|
  spec.version       = ENV['BUILDVERSION'].to_i > 0 ? "#{Prometheus::EnumeratedStore::VERSION}.#{ENV['BUILDVERSION'].to_i}" : Prometheus::EnumeratedStore::VERSION
  spec.authors       = ['Samoilenko Yuri']
  spec.email         = ['kinnalru@gmail.com']
  spec.description   = spec.summary = 'Enchanced File Store for ruby Prometheus library'
  spec.homepage      = 'https://github.com/RnD-Soft/prometheus_enumerated_store'
  spec.license       = 'MIT'

  spec.files         = %w[lib/prometheus_enumerated_store.rb lib/prometheus-enumerated-store.rb
                          lib/prometheus/enumerated_store.rb lib/prometheus/enumerated-store.rb
                          lib/prometheus/enumerated_store/version.rb
                          lib/prometheus/enumerated_store/store.rb
                          lib/prometheus/enumerated_store/pid_enumerator.rb
                          README.md LICENSE].reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.add_runtime_dependency 'prometheus-client'

  spec.add_development_dependency 'bundler', '~> 2.0', '>= 2.0.1'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'
end


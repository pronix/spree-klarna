# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'spree_klarna/version'

Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = 'spree_klarna'
  s.version      = SpreeKlarna::VERSION
  s.summary      = %q{Klarna Checkout based on Klarna API 2.0 for Spree Commerce}
  s.description  = s.summary
  s.required_ruby_version = '>= 1.9.3'

  s.authors      = ['Tobias Bohwalli', 'Abhishek Yadav']
  s.email        = 'hi@futhr.io'
  s.homepage     = 'https://github.com/futhr/spree-klarna'
  s.license      = %q{BSD-3}

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_runtime_dependency 'spree', '~> 2.0.0'
  s.add_runtime_dependency 'excon', '~> 0.25.3'

  s.add_development_dependency 'vcr', '~> 2.5.0'
  s.add_development_dependency 'webmock', '= 1.10'
  s.add_development_dependency 'rspec-rails', '~> 2.13'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'capybara', '~> 2.1.0'
  s.add_development_dependency 'poltergeist', '~> 1.3.0'
  s.add_development_dependency 'shoulda-matchers', '~> 2.2'
  s.add_development_dependency 'elabs_matchers', '~> 0.0.6'
  s.add_development_dependency 'i18n-spec', '~> 0.4.0'
  s.add_development_dependency 'sqlite3', '~> 1.3.7'
  s.add_development_dependency 'simplecov', '~> 0.7.1'
  s.add_development_dependency 'coffee-rails', '~> 3.2.2'
  s.add_development_dependency 'sass-rails', '~> 3.2.6'
  s.add_development_dependency 'fuubar', '>= 0.0.1'
  s.add_development_dependency 'database_cleaner', '~> 1.0.1'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'pry-rails'
end

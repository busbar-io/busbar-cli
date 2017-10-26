require_relative 'lib/busbar_cli/config/version'

Gem::Specification.new do |s|
  s.name        = 'busbar-cli'
  s.version     = BUSBAR_VERSION
  s.date        = '2017-04-17'
  s.summary     = "A CLI for Busbar"
  s.description = "A CLI for Busbar"
  s.authors     = ["Igor Marques", "Max Miorim", "Mark Gergely", "Leon Waldman"]
  s.email       = 'mainteners@busbar.io'
  s.files       = `git ls-files -z lib ; git ls-files -z bin`.split("\x0")
  s.test_files  = s.files.grep(%r{^(test|spec)/})
  s.homepage    =
    'https://github.com/busbar-io/busbar-cli'
  s.license       = 'GPL-3.0'
  s.executables << 'busbar'

  s.add_dependency 'activesupport'
  s.add_dependency 'thor'
  s.add_dependency 'virtus'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'codecov'
end

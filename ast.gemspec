Gem::Specification.new do |s|
  s.name        = 'ast'
  s.version     = '2.4.3'
  s.license     = 'MIT'
  s.authors     = ["whitequark"]
  s.email       = ["whitequark@whitequark.org"]
  s.homepage    = "https://whitequark.github.io/ast/"
  s.summary     = %q{A library for working with Abstract Syntax Trees.}
  s.description = s.summary

  s.files         = %w{LICENSE.MIT README.YARD.md} + Dir.glob("lib/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake',                '~> 13.2'

  s.add_development_dependency 'rspec',               '~> 3.13'
  s.add_development_dependency 'simplecov'

  s.add_development_dependency 'coveralls', '~> 0.8.23'

  s.add_development_dependency 'yard'
  s.add_development_dependency 'kramdown'
end

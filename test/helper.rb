require 'bacon'
require 'bacon/colored_output'

require 'simplecov'
require 'coveralls'

SimpleCov.start do
  self.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
end

require 'ast'

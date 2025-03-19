require 'bundler/gem_tasks'
require 'bundler/setup'
require 'rspec/core'
require 'rspec/core/rake_task'

task :default => :spec

desc "Run test suite"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = true
end

PAGES_REPO = 'git@github.com:whitequark/ast'

desc "Build and deploy documentation to GitHub pages"
task :pages do
  system "git clone #{PAGES_REPO} gh-temp/ -b gh-pages; rm gh-temp/* -rf; touch gh-temp/.nojekyll" or abort
  system "yardoc -o gh-temp/;" or abort
  system "cd gh-temp/; git add -A; git commit -m 'Updated pages.'; git push -f origin gh-pages" or abort
  FileUtils.rm_rf 'gh-temp'
end

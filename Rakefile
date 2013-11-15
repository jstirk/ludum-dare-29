require 'rawr'

task :default => [ 'rawr:clean', 'rawr:jar' ] do
  Rake::Task["rawr:bundle:app"].execute
  Rake::Task["rawr:bundle:exe"].execute
end

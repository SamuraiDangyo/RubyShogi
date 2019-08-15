require 'rake/testtask'

Rake::TestTask.new do | t |
	t.libs << 'test'
	t.test_files = FileList["test/ruby_shogi_test.rb"]
  	t.verbose = true 
end

desc("Run tests")
task(:default => :test)

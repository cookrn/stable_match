#!/usr/bin/env rake

require 'bundler/gem_tasks'
require 'rake/testtask'

namespace :examples do
  desc 'Run any example'
  task :all do
    Dir[ "#{ File.dirname File.expand_path( __FILE__ ) }/examples/**/*.rb" ].each do | file |
      puts
      puts '============================================='
      puts "Start Example: #{ file }"
      puts '============================================='
      puts
      system "ruby #{ file }"
      puts
      puts '============================================='
      puts "End Example: #{ file }"
      puts '============================================='
      puts
    end
  end

  desc 'Run any example'
  task :any do
    exec "ruby #{ Dir[ "#{ File.dirname File.expand_path( __FILE__ ) }/examples/**/*.rb" ].first }"
  end
end
task :example  => 'examples:any'
task :examples => 'examples:all'

namespace :test do
  desc 'Run All The Tests'
  task :all do
    suites = %w(
      test:functional
      test:unit
    )

    final =
      suites.all? do | suite |
        puts '=========================================='
        puts "Running: #{ suite }"
        puts '=========================================='

        begin
          result = Rake::Task[ suite ].invoke
        rescue
          puts '=========================================='
          puts "FAILED: #{ suite }"
          result = false
        ensure
          puts '=========================================='
          puts
        end

        result
      end

    status = final ? 0 : 1
    exit status
  end

  desc 'Run The Functional Tests'
  Rake::TestTask.new( :functional ) do | t |
    t.libs    << [ 'test' ]
    t.pattern = 'test/functional/**/*_test.rb'
    t.verbose = true
  end

  desc 'Run The Unit Tests'
  Rake::TestTask.new( :unit ) do | t |
    t.libs    << [ 'test' ]
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
  end
end

desc 'Run All The Tests'
task :test    => 'test:all'
task :default => :test

#!/usr/bin/env rake

require "bundler/gem_tasks"
require "rake/testtask"

namespace :examples do
  desc "Run any example"
  task :any do
    exec "ruby #{ Dir[ "#{ File.dirname File.expand_path( __FILE__ ) }/examples/**/*.rb" ].first }"
  end
end
task :example => "examples:any"

namespace :test do
  desc "Run All The Tests"
  task :all do
    suites = %w(
      test:functional
      test:unit
    )

    suites.each do | suite |
      puts "=========================================="
      puts "Running: #{ suite }"
      puts "=========================================="
      begin
        Rake::Task[ suite ].invoke
      rescue
        puts "=========================================="
        puts "FAILED: #{ suite }"
      ensure
        puts "=========================================="
        puts "\n"
      end
    end
  end

  desc "Run The Functional Tests"
  Rake::TestTask.new( :functional ) do | t |
    t.libs    << [ "test" ]
    t.pattern = "test/functional/**/*_test.rb"
    t.verbose = true
  end

  desc "Run The Unit Tests"
  Rake::TestTask.new( :unit ) do | t |
    t.libs    << [ "test" ]
    t.pattern = "test/unit/**/*_test.rb"
    t.verbose = true
  end

  desc "Start a watcher process that runs the tests on file changes in `lib` or `test` dirs"
  task :watch do
    exec "rego {lib,test} -- rake"
  end
end

desc "Run All The Tests"
task :test    => "test:all"
task :default => :test

BEGIN {
  def load_bundle_env!
    is_blank = lambda { |o| o.nil? or o.size < 1 }
    ENV[ "BUNDLE_GEMFILE" ] = File.expand_path( "Gemfile" ) unless !is_blank[ ENV[ "BUNDLE_GEMFILE" ] ]
    begin
      require "bundler"
    rescue
      require "rubygems"
      require "bundler"
    ensure
      raise LoadError.new( "Bundler not found!" ) unless defined?( Bundler )
      require "bundler/setup"
    end
  end

  load_bundle_env! unless defined?( Bundler )
}

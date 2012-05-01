require "rubygems"
gem "minitest"

require "minitest/autorun"
require "minitest/pride"

require "stable_match"

support_dir = File.join File.expand_path( File.dirname __FILE__ ) , "support"
Dir[ "#{ support_dir }/**/*.rb" ].each { | f | require f }

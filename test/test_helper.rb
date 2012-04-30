require "rubygems"
gem "minitest"

require "minitest/autorun"
require "minitest/pride"

support_dir = File.expand_path File.dirname( __FILE__ ) , "support"
Dir[ "#{ support_dir }/**/*.rb" ].each { | f | require f }

require "stable_match"

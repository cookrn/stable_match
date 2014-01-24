require 'coveralls'
Coveralls.wear!

require 'rubygems'
gem 'minitest'

require 'minitest/autorun'
require 'minitest/pride'

require 'stable_match/test'

BEGIN {
  def __load_bundle_env!
    is_blank = lambda { |o| o.nil? or o.size < 1 }
    ENV[ 'BUNDLE_GEMFILE' ] = File.expand_path( 'Gemfile' ) if is_blank[ ENV[ 'BUNDLE_GEMFILE' ] ]
    begin
      require 'bundler'
    rescue
      require 'rubygems'
      require 'bundler'
    ensure
      raise LoadError.new( 'Bundler not found!' ) unless defined?( Bundler )
      require 'bundler/setup'
    end
  end

  __load_bundle_env! unless defined?( Bundler )
}

require "fattr"
require "map"

module StableMatch
  def self.run( *args , &block )
    Runner.run *args , &block
  end
end

require "stable_match/candidate"
require "stable_match/runner"
require "stable_match/version"

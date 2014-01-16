require 'yaml'
require 'stable_match/util/initialize_with_defaults'

module StableMatch
  class Runner
    include Util::InitializeWithDefaults

    # Whether the sets have been built into candidate sets
    attr_accessor :built
    alias_method :built? , :built

    # Container for all the candidates
    attr_accessor :candidates

    # Whether the sets have been checked for consistency
    attr_accessor :checked
    alias_method :checked? , :checked

    # The first set to use in the matching
    attr_accessor \
      :candidate_set1, # for Candidates
      :set1            # raw data

    # The second set to use in the matching
    attr_accessor \
      :candidate_set2, # for Candidates
      :set2            # raw data

    # The way in which the run loop executes
    #
    # Should be either: symmetric OR asymmetric
    attr_accessor :strategy

    # Class-level factory method to construct, check, build and run a Runner instance
    def self.run( *args )
      runner = new *args
      runner.check!
      runner.build!
      runner.run
    end

    def initialize( set1 , set2 , strategy = :symmetric )
      @set1     = set1
      @set2     = set2
      @strategy = strategy
    end

    def initialize_defaults!
      @built          ||= false
      @candidates     ||= []
      @checked        ||= false
      @candidate_set1 ||= {}
      @candidate_set2 ||= {}
    end

    # Convert `set1` and `set2` into `candidate_set1` and `candidate_set2`
    # Also, track a master array of `candidates`
    # Mark itself as `built`
    def build!
      set1.each do | target , options |
        candidate =
          Candidate.new \
            target,
            *( options.first.is_a?( Array ) ? options : [ options ] )

        candidates.push candidate
        candidate_set1[ target ] = candidate
      end

      set2.each do | target , options |
        candidate =
          Candidate.new \
            target,
            *( options.first.is_a?( Array ) ? options : [ options ] )

        candidates.push candidate
        candidate_set2[ target ] = candidate
      end

      candidate_set1.each do | target , candidate |
        candidate.preferences =
          candidate.raw_preferences.map { | preference_target | candidate_set2[ preference_target ] }
      end

      candidate_set2.each do | target , candidate |
        candidate.preferences =
          candidate.raw_preferences.map { | preference_target | candidate_set1[ preference_target ] }
      end

      # We've built the candidates
      self.built = true
    end

    # Run basic checks against each raw set
    # Meant to be run before being built into candidate sets
    # Mark itself as `checked`
    def check!
      error     = proc { | message | raise ArgumentError.new( message ) }
      set1_keys = set1.keys
      set2_keys = set2.keys
      set1_size = set1.size
      set2_size = set2.size

      # Check set1
      set1.each do | target , options |
        message = "Preferences for #{ target.inspect } in `set1` do not match availabilities in `set2`!"
        options = options.first if options.first.is_a?( Array )
        error[ message ] unless \
          # Anything there is a preference for is in the other set
          ( options.all? { | preference | set2_keys.include?( preference ) } )
      end

      # Check set2 the same way
      set2.each do | target , options |
        message = "Preferences for #{ target.inspect } in `set2` do not match availabilities in `set1`!"
        options = options.first if options.first.is_a?( Array )
        error[ message ] unless \
          # Anything there is a preference for is in the other set
          ( options.all? { | preference | set1_keys.include?( preference ) } )
      end

      # We've run the check
      self.checked = true
    end

    def inspect
      candidates.map( &:inspect ).join "\n\n"
    end

    alias_method \
      :pretty_inspect,
      :inspect

    # This method respects the runner's strategy!
    #
    # List the remaining candidates that:
    # -> have remaining slots available for matches AND
    # -> have not already proposed to all of their preferences
    def remaining_candidates
      case strategy.to_sym
      when :symmetric
        candidates.reject { | candidate | candidate.full? || candidate.exhausted_preferences? }
      when :asymmetric
        candidate_set1.values.reject { | candidate | candidate.full? || candidate.exhausted_preferences? }
      end
    end

    # While there are remaining candidates, ask each one to propose to all of their preferences until:
    # -> a candidate has proposed to all of their preferences
    # -> a candidate has no more `matching_positions` to be filled
    def run
      while ( rcs = remaining_candidates ).any?
        rcs.each do | candidate |
          while !candidate.exhausted_preferences? && candidate.free?
            candidate.propose_to_next_preference
          end
        end
      end
      self
    end
  end
end

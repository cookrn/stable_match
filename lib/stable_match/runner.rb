module StableMatch
  class Runner
  ## Whether the sets have been built into candidate sets
  #
    fattr( :built ){ false }
    alias_method :built? , :built

  ## Container for all the candidates
  #
    fattr( :candidates ){ [] }

  ## Whether the sets have been checked for consistency
  #
    fattr( :checked ){ false }
    alias_method :checked? , :checked

  ## The first set to use in the matching
  #
    fattr( :candidate_set1 ){ {} } # for Candidates
    fattr :set1                    # raw data

  ## The second set to use in the matching
  #
    fattr( :candidate_set2 ){ {} } # for Candidates
    fattr :set2                    # raw data

  ## Runner::run
  #
  # Class-level factory method to construct, check, build and run a Runner instance
  #
    def self.run( *args , &block )
      runner = new *args , &block
      runner.check!
      runner.build!
      runner.run
    end

    def initialize( *args , &block )
      options = Map.opts args
      @set1   = options.set1 rescue args.shift or raise ArgumentError.new( "No `set1` provided!" )
      @set2   = options.set2 rescue args.shift or raise ArgumentError.new( "No `set2` provided!" )

      yield self if block_given?
    end

  ## Runner#build!
  #
  # Convert `set1` and `set2` into `candidate_set1` and `candidate_set2`
  # Also, track a master array of `candidates`
  # Mark itself as `built`
  #
    def build!
      set1.each do | target , options |
        candidate = Candidate.new target , *[ options ]
        candidates.push candidate
        candidate_set1[ target ] = candidate
      end

      set2.each do | target , options |
        candidate = Candidate.new target , *[ options ]
        candidates.push candidate
        candidate_set2[ target ] = candidate
      end

      candidate_set1.each do | target , candidate |
        candidate.preferences.map! { | preference_target | candidate_set2[ preference_target ] }
      end

      candidate_set2.each do | target , candidate |
        candidate.preferences.map! { | preference_target | candidate_set1[ preference_target ] }
      end

    ## We've built the candidates
    #
      self.built = true
    end

  ## Runner#check!
  #
  # Run basic checks against each raw set
  # Meant to be run before being built into candidate sets
  # Mark itself as `checked`
  #
    def check!
      error     = proc { | message | raise ArgumentError.new( message ) }
      set1_keys = set1.keys
      set2_keys = set2.keys
      set1_size = set1.size
      set2_size = set2.size

    ## Check set1
    #
      set1.each do | target , options |
        message = "Preferences for #{ target.inspect } in `set1` do not match availabilities in `set2`!"
        error[ message ] unless \
        ## Anything there is a preference for is in the other set
        #
          ( options[ :preferences ].inject( true ){ | memo , preference | memo && set2_keys.include?( preference ) } )
      end

    ## Check set2 the same way
    #
      set2.each do | target , options |
        message = "Preferences for #{ target.inspect } in `set2` do not match availabilities in `set1`!"
        error[ message ] unless \
          ( options[ :preferences ].inject( true ){ | memo , preference | memo && set1_keys.include?( preference ) } )
      end

    ## We've run the check
    #
      self.checked = true
    end

    def inspect
      require "yaml"

      inspection = proc do | set |
        set.keys.inject( Hash.new ) do | hash , key |
          candidate = set[ key ]
          preferences = candidate.preferences

          hash.update(
            key => {
              'matches'     => candidate.matches.map( &:target ),
              'preferences' => candidate.preferences.map( &:target ),
              'proposals'   => candidate.proposals.map( &:target )
            }
          )
        end
      end

      {
        'candidate_set1' => inspection[ candidate_set1 ],
        'candidate_set2' => inspection[ candidate_set2 ]
      }.to_yaml
    end

  ## Runner#remaining_candidates
  #
  # List the remaining candidates that:
  # -> have remaining slots available for matches AND
  # -> have not already proposed to all of their preferences
  #
    def remaining_candidates
      candidates.reject{ | candidate | candidate.full? || candidate.exhausted_preferences? }
    end

  ## Runner#remaining_candidates
  #
  # While there are remaining candidates, ask each one to propose to all of their preferences until:
  # -> a candidate has proposed to all of their preferences
  # -> a candidate has no more `matching_positions` to be filled
  #
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

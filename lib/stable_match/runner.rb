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
    fattr( :candidate_set1 ){ {} }
    fattr :set1

  ## The second set to use in the matching
  #
    fattr( :candidate_set2 ){ {} }
    fattr :set2

  ## The maximum time the algorithm should run in seconds
  #
    fattr( :threshold ){ 1 }

    def self.run( *args , &block )
      runner = new *args , &block
      runner.check!
      runner.build!
      runner.run
    end

    def initialize( *args , &block )
      options    = Map.opts args
      @set1      = options.set1 rescue args.shift or raise ArgumentError.new( "No `set1` provided!" )
      @set2      = options.set2 rescue args.shift or raise ArgumentError.new( "No `set2` provided!" )

      @threshold = options.threshold if options.get( :threshold )

      yield self if block_given?
    end

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

    def inspect
      summary =
        {
          'candidate_set1' => 
            @candidate_set1.keys.inject(Hash.new) do |hash, key|
              candidate = @candidate_set1[key]
              preferences = candidate.preferences

              hash.update(
                candidate.target => {
                  'matches'     => candidate.matches.map(&:target),
                  'preferences' => candidate.preferences.map(&:target),
                  'proposals'   => candidate.proposals.map(&:target)
                }
              )
            end

        }
      summary.to_yaml
    end

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

    def remaining_candidates
      candidates.reject{ | candidate | candidate.full? || candidate.exhausted_preferences? }
    end

    def results_description
      "\nMatch results:\n".tap do |str|
        candidate_set1.each { |target, candidate| str << candidate.description + "\n" }
        str << "Unmatched Applicants: #{applicants.reject {|_,a|a.matched?}.map {|n,_|n}.join(', ')}"
        str << "\n\n"
        applicants.each { |name, applicant| str << applicant.description + "\n" }
        str << "Unmatched Programs: #{programs.reject {|_,p|p.matched?}.map {|n,_|n}.join(', ')}"
      end
    end

    def run
      while ( candidates = remaining_candidates ).any?
        candidates.each do | candidate |
          while !candidate.exhausted_preferences? && candidate.free?
            candidate.propose_to_next_preference
          end
        end
      end

p self

      self
    end
  end
end

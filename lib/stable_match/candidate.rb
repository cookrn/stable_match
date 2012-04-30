module StableMatch
  class Candidate
  ## The matches this candidate has attained
  #
    fattr( :matches ){ [] }

  ## The number of matches the candidate is able to make
  #
    fattr( :match_positions ){ 1 }

  ## The tracked position for preferences that have been attempted for matches
  #
    fattr( :preference_position ){ -1 }

  ## An ordered array of candidates where, the lower the index, the higher the preference
  #
  # WARNING -- this may be instantiated with targets at first that get converted to Candidates
  #
    fattr( :preferences ){ [] }

  ## The array to track proposals that have already been made
  #
    fattr( :proposals ){ [] }

  ## The object that the candidate represents
  #
    fattr :target

    def initialize( *args )
      options      = Map.opts args
      @target      = options.target      rescue args.shift or raise ArgumentError.new( "No `target` provided!" )
      @preferences = options.preferences rescue args.shift or raise ArgumentError.new( "No `preferences` provided!" )

      @positions   = options.positions if options.get( :positions )
    end

    def better_match?( other )
      return true if matches.size < match_positions
      preference_index_of_other = ( preferences.index( other ) or ( preferences.size + 1 ) )
      matches.inject( false ){ | memo , match | memo || ( preference_index_of_other < preferences.index( match ) ) }
    end

    def exhausted_preferences?
      preference_position >= preferences.size - 1
    end

    def free!( other = nil )
      self.matches.sort! { | m1 , m2 | preferences.index( m1 ) <=> preferences.index( m2 ) }

      other = case
              when !other.nil?
                self.matches = self.matches - [ other ]
                other
              when !matches.empty?
                self.matches.pop
              else
                return
              end

      other.free! self
    end

    def free?
      !matched?
    end

    def match!( other )
      unless matched?( other )
        matches << other
        other.match! self
        true
      else
        false
      end
    end

    def matched?( other = nil )
      if other.nil?
        matches.length >= match_positions
      else
        matches.include? other
      end
    end

    def next_preference!
      self.preference_position += 1
      preferences[ preference_position ]
    end

    def prefers?( other )
      preferences.include? other
    end

    def propose_to( other )
      return matched?( other ) if proposals.include?( other )
      proposals << other
      other.respond_to_proposal_from self
    end

    def propose_to_next_preference
      propose_to next_preference!
    end

    def respond_to_proposal_from( other )
      case
      when !prefers?( other ) then false
      when free?
        match! other
      when better_match?( other )
        free!        # clear out existing match
        match! other # set new match
      else
        false
      end
    end
  end
end

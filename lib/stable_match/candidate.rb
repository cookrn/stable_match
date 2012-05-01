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

    def initialize(*args)
      options      = Map.opts(args)
      @target      = options.target      rescue args.shift or raise ArgumentError.new( "No `target` provided!" )
      @preferences = options.preferences rescue args.shift or raise ArgumentError.new( "No `preferences` provided!" )

      @match_positions = options.match_positions if options.get( :match_positions )
    end

  ## Candidate#better_match?
  #
  # Is the passed candidate a better match than any of the current matches?
  #
  # ARG: `other` -- another Candidate instance to check against the current set
  #
    def better_match?( other )
      return true if prefers?( other ) && free?
      preference_index = preferences.index other
      match_preference_indexes = matches.map { | match | preferences.index match }
      preference_index and match_preference_indexes.any? { |i| i > preference_index }
    end

  ## Candidate#exhausted_preferences?
  #
  # Have all possible preferences been cycled through?
  #
    def exhausted_preferences?
      preference_position >= preferences.size - 1
    end

  ## Candidate#free?
  #
  # Is there available positions for more matches based on the defined `match_positions`?
  #
    def free?
      matches.length < match_positions
    end

  ## Candidate#free!
  #
  # Delete the least-preferred candidate from the matches array
  #
    def free!
      return false if matches.empty?
      match_preference_indexes = matches.map { | match | preferences.index match }
      max                      = match_preference_indexes.max # The index of the match with the lowest preference
      candidate_to_reject      = preferences[ max ]

    ## Delete from both sides
    #
      candidate_to_reject.matches.delete self
      self.matches.delete candidate_to_reject
    end

  ## Candidate#full?
  #
  # Are there no remaining positions available for matches?
  #
    def full?
      !free?
    end

    def inspect
      require "yaml"

      {
        :target              => target,
        :match_positions     => match_positions,
        :matches             => matches.map( &:target ),
        :preference_position => preference_position,
        :preferences         => preferences.map( &:target ),
        :proposals           => proposals.map( &:target )
      }.to_yaml
    end

  ## Candidate#match!
  #
  # Match with another Candidate
  #
  # ARG: `other` -- another Candidate instance to match with
  #
    def match!( other )
      return false unless prefers?( other ) && !matched?( other )
      matches       << other
      other.matches << self
    end

  ## Candidate#matched?
  #
  # If no argument is passed: Do we have at least as many matches as available `match_positions`?
  # If another Candidate is passed: Is that candidate included in the matches?
  #
  # ARG: `other` [optional] -- another Candidate instance
  #
    def matched?( other = nil )
      return full? if other.nil?
      matches.include? other
    end

  ## Candidate#next_preference!
  #
  # Increment `preference_position` and return the preference at that position
  #
    def next_preference!
      self.preference_position += 1
      preferences.fetch preference_position
    end

  ## Candidate#prefers?
  #
  # Is there a preference for the passed Candidate?
  #
  # ARG: `other` -- another Candidate instance
  #
    def prefers?( other )
      preferences.include? other
    end

  ## Candidate#propose_to
  #
  # Track that a proposal was made then ask the other Candidate to respond to a proposal
  #
  # ARG: `other` -- another Candidate instance
  #
    def propose_to( other )
      proposals << other
      other.respond_to_proposal_from self
    end

  ## Candidate#propose_to_next_preference
  #
  # Send a proposal to the next tracked preference
  #
    def propose_to_next_preference
      propose_to next_preference!
    end

  ## Candidate#respond_to_proposal_from
  #
  # Given another candidate, respond properly based on current state
  #
  # ARG: `other` -- another Candidate instance
  #
    def respond_to_proposal_from( other )
      case
      ## Is there a preference for the candidate?
      #
        when !prefers?( other )
          false

      ## Are there available positions for more matches?
      #
        when free?
          match! other

      ## Is the passed Candidate a better match than any other match?
      #
        when better_match?( other )
          free!
          match! other

        else
          false
      end
    end
  end
end

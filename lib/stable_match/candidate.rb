require 'yaml'
require 'stable_match/util/initialize_with_defaults'

module StableMatch
  class Candidate
    include Util::InitializeWithDefaults

    # The matches this candidate has attained
    attr_accessor :matches

    # The number of matches the candidate is able to make
    attr_accessor :match_positions

    # The tracked position for preferences that have been attempted for matches
    attr_accessor :preference_position

    # An ordered array of candidates where, the lower the index, the higher the preference
    #
    # WARNING -- this may be instantiated with targets at first that get converted to Candidates
    attr_accessor :preferences

    # The array to track proposals that have already been made
    attr_accessor :proposals

    # An ordered array of raw preference values
    attr_accessor :raw_preferences

    # The object that the candidate represents
    attr_accessor :target

    def initialize( target , raw_preferences , match_positions = 1 )
      @target          = target
      @raw_preferences = raw_preferences
      @match_positions = match_positions
    end

    def initialize_defaults!
      @matches             ||= []
      @preference_position ||= -1
      @preferences         ||= []
      @proposals           ||= []
      @raw_preferences     ||= []
    end

    # Is the passed candidate a better match than any of the current matches?
    #
    # ARG: `other` -- another Candidate instance to check against the current set
    def better_match?( other )
      return true if prefers?( other ) && free?
      preference_index = preferences.index other
      match_preference_indexes = matches.map { | match | preferences.index match }
      preference_index and match_preference_indexes.any? { |i| i > preference_index }
    end

    # Have all possible preferences been cycled through?
    def exhausted_preferences?
      preference_position >= preferences.size - 1
    end

    # Is there available positions for more matches based on the defined `match_positions`?
    def free?
      matches.length < match_positions
    end

    # Delete the least-preferred candidate from the matches array
    def free!
      return false if matches.empty?
      match_preference_indexes = matches.map { | match | preferences.index match }
      max                      = match_preference_indexes.max # The index of the match with the lowest preference
      candidate_to_reject      = preferences[ max ]

      # Delete from both sides
      candidate_to_reject.matches.delete self
      self.matches.delete candidate_to_reject
    end

    # Are there no remaining positions available for matches?
    def full?
      !free?
    end

    def inspect
      {
        'target'              => target,
        'match_positions'     => match_positions,
        'matches'             => matches.map( &:target ),
        'preference_position' => preference_position,
        'preferences'         => preferences.map( &:target ),
        'proposals'           => proposals.map( &:target ),
        'raw_preferences'     => raw_preferences
      }.to_yaml
    end

    alias_method \
      :pretty_inspect,
      :inspect

    # Match with another Candidate
    #
    # ARG: `other` -- another Candidate instance to match with
    def match!( other )
      return false unless prefers?( other ) && !matched?( other )
      matches       << other
      other.matches << self
    end

    # If no argument is passed: Do we have at least as many matches as available `match_positions`?
    # If another Candidate is passed: Is that candidate included in the matches?
    #
    # ARG: `other` [optional] -- another Candidate instance
    def matched?( other = nil )
      return full? if other.nil?
      matches.include? other
    end

    # Increment `preference_position` and return the preference at that position
    def next_preference!
      self.preference_position += 1
      preferences.fetch preference_position
    end

    # Is there a preference for the passed Candidate?
    #
    # ARG: `other` -- another Candidate instance
    def prefers?( other )
      preferences.include? other
    end

    # Track that a proposal was made then ask the other Candidate to respond to a proposal
    #
    # ARG: `other` -- another Candidate instance
    def propose_to( other )
      proposals << other
      other.respond_to_proposal_from self
    end

    def propose_to_next_preference
      propose_to next_preference!
    end

    # Given another candidate, respond properly based on current state
    #
    # ARG: `other` -- another Candidate instance
    def respond_to_proposal_from( other )
      case
        # Is there a preference for the candidate?
        when !prefers?( other )
          false

        # Are there available positions for more matches?
        when free?
          match! other

        # Is the passed Candidate a better match than any other match?
        when better_match?( other )
          free!
          match! other

        else
          false
      end
    end
  end
end

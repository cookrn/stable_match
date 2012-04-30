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

      @match_positions   = options.match_positions if options.get( :match_positions )
    end

    def exhausted_preferences?
      preference_position >= preferences.size - 1
    end

    def propose_to_next_preference
      preference = next_preference!
      propose_to(preference)
    end

    def next_preference!
      self.preference_position += 1
      preferences.fetch(preference_position)
    end

    def propose_to(other)
      proposals << other
      other.respond_to_proposal_from(self)
    end

    def respond_to_proposal_from(other)
      case
        when !prefers?(other)
          false
        when free?
          match!(other)
        when better_match?(other)
          free!
          match!(other)
        else
          false
      end
    end

    def prefers?(other)
      preferences.include?(other)
    end

    def free?
      matches.length < match_positions
    end

    def full?
      !free?
    end

    def matched?(other = nil)
      if other.nil?
        matches.length >= match_positions
      else
        matches.include?(other)
      end
    end

    def match!(other)
      matches << other
      other.matches << self
      matches.uniq!
      other.matches.uniq!
    end

    def better_match?(other)
      index = preferences.index(other)
      indexes = matches.map{|match| preferences.index(match)}
      index and indexes.any?{|i| i > index}
    end

    def free!
      indexes = matches.map{|match| preferences.index(match)}
      max = indexes.max
      reject = preferences[max]
      reject.matches.delete(self)
      self.matches.delete(reject)
    end
  end
end

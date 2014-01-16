require 'test_helper'

class StableMatch::CandidateTest < StableMatch::Test
  def setup
    @candidate1 = StableMatch::Candidate.new 1 , [ 2 , 3 ]
    @candidate2 = StableMatch::Candidate.new 2 , [ 1 , 3 ]
    @candidate3 = StableMatch::Candidate.new 3 , [ 2 , 1 ]

    @candidate1.preferences = [ @candidate2 , @candidate3 ]
    @candidate2.preferences = [ @candidate1 , @candidate3 ]
    @candidate3.preferences = [ @candidate2 , @candidate1 ]
  end

  def test_match_positions_option_overrides_default
    assert{ @candidate1.match_positions }

    match_positions = 3
    candidate       = StableMatch::Candidate.new( 1 , [ 2 , 3 ] , match_positions )
    assert{ candidate.match_positions == match_positions }
  end

  def test_better_match_returns_false_if_not_preferred
    candidate4 = StableMatch::Candidate.new 4 , [ @candidate3 , @candidate2 ]
    assert{ !@candidate1.better_match?( candidate4 ) }
  end

  def test_better_match_returns_false_if_already_matched
    @candidate1.match! @candidate2
    assert{ !@candidate1.better_match?( @candidate2 ) }
  end

  def test_better_match_returns_true_if_free
    assert{ @candidate1.better_match? @candidate2 }
  end

  def test_better_match_returns_true_if_other_has_higher_preference
    @candidate1.match! @candidate3
    assert{ @candidate1.better_match? @candidate2 }
  end

  def test_exhausted_preferences_returns_false_if_not_all_preferences_have_been_checked
    assert{ !@candidate1.exhausted_preferences? }
  end

  def test_exhausted_preferences_returns_true_if_all_preferences_have_been_checked
    @candidate1.preference_position = @candidate1.preferences.size
    assert{ @candidate1.exhausted_preferences? }
  end

  def test_free_returns_false_if_all_match_positions_are_filled
    @candidate1.match! @candidate2
    assert{ !@candidate1.free? }
  end

  def test_free_returns_true_if_not_all_match_positions_are_filled
    assert{ @candidate1.free? }
  end

  def test_free_returns_false_if_there_are_no_matches
    assert{ !@candidate1.free! }
  end

  def test_free_deletes_the_least_preferred_match
    @candidate1.match! @candidate2
    assert{ @candidate1.free! }
    assert{ !@candidate1.matches.include?( @candidate2 ) }
  end

  def test_free_deletes_the_least_preferred_match_from_both_sides
    @candidate1.match! @candidate2
    assert{ @candidate1.free! }
    assert{ !@candidate2.matches.include?( @candidate1 ) }
  end

  def test_free_returns_false_if_all_match_positions_are_filled
    @candidate1.match! @candidate2
    assert{ @candidate1.full? }
  end

  def test_free_returns_true_if_not_all_match_positions_are_filled
    assert{ !@candidate1.full? }
  end

  def test_match_returns_false_if_other_is_not_preferred
    candidate4 = StableMatch::Candidate.new 4 , [ @candidate3 , @candidate2 ]
    assert{ !@candidate1.match!( candidate4 ) }
  end

  def test_match_returns_false_if_already_matched
    assert{ @candidate1.match! @candidate2 }
    assert{ !@candidate1.match!( @candidate2 ) }
  end

  def test_match_adds_other_to_matches_array
    assert{ @candidate1.match! @candidate2 }
    assert{ @candidate1.matches.include? @candidate2 }
  end

  def test_match_adds_self_to_others_matches_array
    assert{ @candidate1.match! @candidate2 }
    assert{ @candidate2.matches.include? @candidate1 }
  end

  def test_matched_returns_full_with_no_args
    @candidate1.match! @candidate2
    assert{ @candidate1.matched? == @candidate1.full? }
  end

  def test_matched_returns_whether_passed_candidate_is_a_match
    @candidate1.match! @candidate2
    assert{ @candidate1.matched? @candidate2 }
  end

  def test_next_preference_increments_the_preference_position
    preference_position = @candidate1.preference_position
    assert{ @candidate1.next_preference! }
    assert{ preference_position != @candidate1.preference_position }
  end

  def test_next_preference_returns_a_candidate
    expected_candidate = @candidate1.preferences.first
    assert{ expected_candidate == @candidate1.next_preference! }
  end

  def test_prefers_checks_for_existence_of_candidate_in_preferences
    assert{ @candidate1.prefers? @candidate2 }
    assert{ !@candidate1.prefers?( "bogus" ) }
  end

  def test_propose_to_tracks_proposals
    assert{ @candidate1.propose_to @candidate2 }
    assert{ @candidate1.proposals.include? @candidate2 }
  end

  def test_respond_to_proposal_from_returns_false_if_other_is_not_preferred
    candidate4 = StableMatch::Candidate.new 4 , [ @candidate3 , @candidate2 ]
    assert{ !@candidate1.respond_to_proposal_from( candidate4 ) }
  end

  def test_respond_to_proposal_from_matches_if_preferred_and_free
    assert{ @candidate1.respond_to_proposal_from @candidate2 }
  end

  def test_respond_to_proposal_from_frees_and_matches_if_full
    assert{ @candidate1.respond_to_proposal_from @candidate3 }
    assert{ @candidate3.matched? @candidate1 }
    assert{ @candidate1.respond_to_proposal_from @candidate2 }
    assert{ @candidate2.matched? @candidate1 }
    assert{ !@candidate3.matched?( @candidate1 ) }
  end
end

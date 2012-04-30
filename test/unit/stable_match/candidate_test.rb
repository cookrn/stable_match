require "test_helper"

class StableMatch::CandidateTest < MiniTest::Unit::TestCase
  def setup
    @candidate1 = StableMatch::Candidate.new 1 , { 2 => 70 , 3 => 30 }
    @candidate2 = StableMatch::Candidate.new 2 , { 1 => 50 , 3 => 50 }
    @candidate3 = StableMatch::Candidate.new 3 , { 1 => 30 , 2 => 70 }
  end

  def test_accepts_args_as_named_options_or_positionally
    target      = 1
    preferences = 2

    assert{ StableMatch::Candidate.new( target , preferences ) }
    assert{ StableMatch::Candidate.new( :target => target , :preferences => preferences ) }

    candidate = assert{ StableMatch::Candidate.new( target , :preferences => preferences ) }
    assert{ candidate.target == target }

    candidate = assert{ StableMatch::Candidate.new( preferences , :target => target ) }
    assert{ candidate.preferences == preferences }
  end

  def test_match_bang_sets_match_on_both_objects
    assert{ @candidate1.match! @candidate2 }
    assert{ @candidate1.match == @candidate2 }
    assert{ @candidate2.match == @candidate1 }
  end

  def test_free_bang_clears_a_match
    @candidate1.match! @candidate2

    assert{ @candidate1.match }
    assert{ @candidate1.free!.nil? }
  end

  def test_free_and_matched_are_opposites
    assert{ @candidate1.free? }
    assert{ !@candidate1.matched? }

    @candidate1.match! @candidate2

    assert{ !@candidate1.free? }
    assert{ @candidate1.matched? }
  end

  def test_better_match_respects_preferences
    @candidate1.match! @candidate3
    assert{ @candidate1.better_match? @candidate2 }

    @candidate2.match! @candidate3
    assert{ !@candidate2.better_match?( @candidate1 ) }
    assert{ !@candidate3.better_match?( @candidate1 ) }
  end

  def test_proposals_are_tracked
    assert{ @candidate1.propose_to @candidate2 }
    assert{ @candidate1.proposals.include? @candidate2 }
  end

  def test_proposals_are_not_duplicated
    @candidate1.propose_to @candidate2
    assert{ @candidate1.propose_to @candidate2 }
    assert{ @candidate1.proposals.size == 1 }
  end

  def test_properly_responds_to_proposals
    assert{ @candidate1.respond_to_proposal_from @candidate2 }
    assert{ @candidate1.match == @candidate2 }

    @candidate1.respond_to_proposal_from @candidate3
    assert{ @candidate1.match == @candidate2 }
  end
end
